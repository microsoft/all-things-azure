from azure.identity import DefaultAzureCredential    
from azure.servicebus import ServiceBusClient, ServiceBusReceiveMode    
import os    
import json
import subprocess  
  
# service bus queues    
running_queue = os.environ['SERVICE_BUS_QUEUE_RUNNING']   
fully_qualified_namespace = os.environ['SERVICE_BUS_FQDN']    
credential = DefaultAzureCredential()  
  
print("Service Bus Complete Started")   
  
# directory containing completed tasks  
completed_dir = '/mnt/output/run/completed/'  
  
# list all files in the directory  
completed_files = os.listdir(completed_dir)  
  
# process each completed file  
for file_name in completed_files:  
    # the file name is the target task value  
    target_task_value = file_name  
  
    print("Processing completed job " + target_task_value)  
  
    # receives messages in the running queue  
    with ServiceBusClient(fully_qualified_namespace, credential) as client:    
        with client.get_queue_receiver(running_queue, receive_mode=ServiceBusReceiveMode.PEEK_LOCK, max_wait_time=30) as receiver:    
            for msg in receiver:    
                # get the value of task    
                data = json.loads(str(msg))    
                task_value = data.get('task')    
                if task_value == target_task_value:  
                    print("Removing job-" + task_value + " from running queue and marking as completed")  
                    receiver.complete_message(msg)  # complete the message to remove it from the queue  
                    break  
                else:  
                    receiver.abandon_message(msg)  # abandon the message to release the lock
            # Remove the file from the directory after processing
            try:
                os.remove(os.path.join(completed_dir, file_name))
                print("Removed file - " + file_name)
            except FileNotFoundError:
                print("Nothing to do here. File not found - " + file_name)
            
            # Execute the kubectl command to delete the job from the database           
            subprocess.run(["kubectl", "exec", "stormbreaker-api-0", "--", "sqlite3", "db.sqlite3", "delete from  api_job where task == '" + task_value + "'"], check=True)
            print("Deleted job from database - " + task_value)