# sender.py  
from azure.identity import DefaultAzureCredential
from azure.servicebus import ServiceBusClient, ServiceBusMessage
import os  
import json  

fully_qualified_namespace = os.environ['SERVICE_BUS_FQDN']

credential = DefaultAzureCredential()

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

