from azure.identity import DefaultAzureCredential
from azure.servicebus import ServiceBusClient, ServiceBusReceiveMode, ServiceBusMessage
import os
import json
import subprocess


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

# service bus queues
dispatch_queue = os.environ['SERVICE_BUS_QUEUE_DISPATCH']
running_queue = os.environ['SERVICE_BUS_QUEUE_RUNNING']
fully_qualified_namespace = os.environ['SERVICE_BUS_FQDN']

credential = DefaultAzureCredential()

print("Service Bus Receiver Started")
# receives messages in the dispatcher queue
with ServiceBusClient(fully_qualified_namespace, credential) as client:
    with client.get_queue_receiver(dispatch_queue, receive_mode=ServiceBusReceiveMode.RECEIVE_AND_DELETE, max_wait_time=30) as receiver:
        for msg in receiver: 
            print(str(msg))
						
			# get the value of task
            data = json.loads(str(msg))
            task_value = data.get('task')

            # save the file for further processing
            if not os.path.exists('/mnt/input/jobs'):  
            	os.makedirs('/mnt/input/jobs')
                
            filename = '/mnt/input/jobs/job_{}.json'.format(task_value)
            with open(filename, 'w') as file:
                file.write(json.dumps(data))

            # Read the template from the file  
            with open('/mnt/input/templates/adcirc-hpc.tpl', 'r') as file:  
                template = file.read()  
              
            # Substitute the variables in the template  
            modified_template = template.replace("$JOB_NAME", data["task"])
            modified_template = modified_template.replace("$JOB_SLOTS", str(data["slots"]))
            modified_template = modified_template.replace("$JOB_NP", str(data["np"]))
            modified_template = modified_template.replace("$JOB_CUSTOMER", data["customer"].lower())
            modified_template = modified_template.replace("$JOB_SIMULATION", data["simulation"].lower())
              
            # Create the output filename by appending the task name  
            output_dir = '/mnt/output/run/' + data["customer"].lower() + "/" + data["simulation"].lower() + "/" + data["task"]
            if not os.path.exists(output_dir):
            	os.makedirs(output_dir)
            
            output_filename = output_dir + "/" + "adcirc-hpc-" + data["customer"].lower() + data["simulation"].lower() + data["task"] + ".yaml"  
              
            # Write the modified template to a file  
            with open(output_filename, "w") as file:  
                file.write(modified_template)
            
            # Execute the kubectl command  
            subprocess.run(["kubectl", "apply", "-f", output_filename], check=True)

            # updates the running queue
            json_data = json.dumps(data) 
            send_message(fully_qualified_namespace, running_queue, json_data)
