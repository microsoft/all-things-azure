from azure.identity import DefaultAzureCredential
from azure.servicebus import ServiceBusClient, ServiceBusReceiveMode
import os
import json

# service bus queues
running_queue = os.environ['SERVICE_BUS_QUEUE_RUNNING']
fully_qualified_namespace = os.environ['SERVICE_BUS_FQDN']

credential = DefaultAzureCredential()

def receive_messages(fully_qualified_namespace, running_queue):
    # receives messages in the dispatcher queue
    with ServiceBusClient(fully_qualified_namespace, credential) as client:
        with client.get_queue_receiver(running_queue, receive_mode=ServiceBusReceiveMode.PEEK_LOCK, max_wait_time=3) as receiver:
            messages = []
            for msg in receiver:
                messages.append(str(msg))
            return messages