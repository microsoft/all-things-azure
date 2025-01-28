import streamlit as st    
import json    
import uuid    
import os  
import json
import pandas as pd
import time 
from azure.servicebus import ServiceBusClient, ServiceBusMessage, ServiceBusReceiveMode
from azure.identity import DefaultAzureCredential
  
# service bus queues  
dispatch_queue = os.environ['SERVICE_BUS_QUEUE_DISPATCH']  
delete_queue = os.environ['SERVICE_BUS_QUEUE_DELETE']  
running_queue = os.environ['SERVICE_BUS_QUEUE_RUNNING']  
fully_qualified_namespace = os.environ['SERVICE_BUS_FQDN']  

# get the credentials
credential = DefaultAzureCredential()

def receive_messages(fully_qualified_namespace, running_queue):
    # receives messages in the dispatcher queue
    with ServiceBusClient(fully_qualified_namespace, credential) as client:
        with client.get_queue_receiver(running_queue, receive_mode=ServiceBusReceiveMode.PEEK_LOCK, max_wait_time=3) as receiver:
            messages = []
            for msg in receiver:
                messages.append(str(msg))
            return messages

@st.cache_data
def refresh_data():
    running_tasks = receive_messages(fully_qualified_namespace, running_queue)  
        
    data = []    
    for task in running_tasks:    
        json_data = json.loads(task)
        data.append(json_data)
           
    df = pd.DataFrame(data)  
    test = st.data_editor(df, hide_index=True)  
    
def send_to_delete_queue(selected_rows):  
    json_data = selected_rows.to_json(orient='records')  
    print('Deleting ', json_data)  

def load_json_file(filename):  
    with open(filename) as job:  
        data = json.load(job)  
    return json.dumps(data)  
  
def send_message(fully_qualified_namespace, queue_name, json_data):
    with ServiceBusClient(fully_qualified_namespace, credential) as client:  
        with client.get_queue_sender(queue_name) as sender:  
            single_message = ServiceBusMessage(json_data)  
            sender.send_messages(single_message)  
            print("Message sent to", queue_name)
            print(single_message)  

def main():
    # header
    col1, col2, col3 = st.columns([0.1,0.8, 0.1])  
    with col1:  
        st.write("")  
    
    with col2:  
        st.text("""  
        -------------------------------------------  
        |S|t|o|r|m|b|r|e|a|k|e|r| |T|e|r|m|i|n|a|l|  
        -------------------------------------------  
        """)  
    
    with col3:  
        st.write("")  

    # sidebar
    st.sidebar.image("logo.jpg", width=100)  
    customer = st.sidebar.text_input('Customer', value="Calgary")   
    task = str(uuid.uuid4())  # Auto generate a GUID for the task      
    np = st.sidebar.number_input('NP', min_value=0, max_value=280, value=280, help="Total number of cores to be used")    
    slots = st.sidebar.number_input('Slots', min_value=0, max_value=96, value=96, help="The number of cores per VM")    
    simulation = st.sidebar.selectbox('Simulation', ['Guam', 'Katrina', 'Gustav'], help="The simulation we want to run")  # Replace with your options    

    # check if all fields are filled    
    if customer and np >=0 and slots >= 0 and simulation:      
        if customer and customer.isalpha():  
            if st.sidebar.button('Deploy'):      
                data = {      
                    "customer": customer,      
                    "task": task,      
                    "np": np,      
                    "slots": slots,      
                    "simulation": simulation      
                }      
                json_data = json.dumps(data)    
                if not os.path.exists('jobs'):    
                    os.makedirs('jobs')    
                filename = 'jobs/job_{}.json'.format(task)    
                with open(filename, 'w') as f:    
                    json.dump(data, f)    
                deploy_data = load_json_file(filename)  
                send_message(fully_qualified_namespace, dispatch_queue, json_data)  
                st.success('Simulation started')    
                st.write('Here is your simulation details:')
                st.json(json_data)
        else:  
            st.error("Input is not valid. Please do not enter any special characters or spaces.")  
    else:    
        st.warning('Please fill in all fields.')

 
    # refresh button
    st.write("Current tasks")
    refresh_data()
    
    refresh_button = st.button('Refresh')
    if refresh_button:
        refresh_data.clear()
        message = st.success('Cache is cleared!')
        time.sleep(5)
        message.empty()

    # User inputs the value from the table into a text_input  
    task = st.text_input('Enter the task to delete')  
    
    # Create a delete button  
    delete_button = st.button('Delete')  
    
    # Action when delete button is clicked  
    if delete_button:
        task = task.replace('"', '')
        # Send the message
        delete_task = {
            "task": task
        }

        send_message(fully_qualified_namespace, delete_queue, json.dumps(delete_task))
        st.success(f'Task deleted:\n {delete_task}.')  

    # footnote    
    st.write('[Stormbreaker](https://github.com/appdevgbb/Project-Stormbreaker/) is brought you by the [Azure App Innovation Global Black Belt team](https://azureglobalblackbelts.com/)')  


if __name__ == '__main__':
    main()