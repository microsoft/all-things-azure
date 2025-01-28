from .models import Job
from .serializers import JobSerializer
from azure.servicebus import ServiceBusClient, ServiceBusMessage, ServiceBusReceiveMode
from azure.identity import DefaultAzureCredential
from django.http import JsonResponse
from django.shortcuts import render
from rest_framework import viewsets, status
from rest_framework.response import Response
import json
import os

# service bus queues  
dispatch_queue = os.environ.get('SERVICE_BUS_QUEUE_DISPATCH', 'dispatch_queue')
delete_queue = os.environ.get('SERVICE_BUS_QUEUE_DELETE', 'delete_queue')
running_queue = os.environ.get('SERVICE_BUS_QUEUE_RUNNING', 'running_queue')  
fully_qualified_namespace = os.environ.get('SERVICE_BUS_FQDN', 'fully_qualified_name')  

# get the credentials
credential = DefaultAzureCredential()

# Function to receive messages from the Service Bus  
def receive_messages(fully_qualified_namespace, running_queue):  
    with ServiceBusClient(fully_qualified_namespace, credential) as client:
        with client.get_queue_receiver(running_queue, receive_mode=ServiceBusReceiveMode.PEEK_LOCK, max_wait_time=3) as receiver:  
            messages = []  
            for msg in receiver:  
                messages.append(str(msg))  
            return messages  

# Function to send messages to the Service Bus
def send_message(fully_qualified_namespace, queue_name, json_data):
    # with ServiceBusClient(fully_qualified_namespace, credential) as client:  
    with ServiceBusClient(fully_qualified_namespace, credential) as client:
        with client.get_queue_sender(queue_name) as sender:  
            single_message = ServiceBusMessage(json_data)  
            sender.send_messages(single_message)  
            print("Message sent to", queue_name)
            print(single_message)
  
class JobViewset(viewsets.ModelViewSet):  
    queryset = Job.objects.all().order_by("-id")  
    serializer_class = JobSerializer
    
    # create method - we need to save the job locally on the sqlite db and
    # send a message to the dispatch queue in the service bus
    def create(self, request, *args, **kwargs):  
        serializer = self.get_serializer(data=request.data)  
        serializer.is_valid(raise_exception=True)  
        self.perform_create(serializer)  
          
        # Add your custom code here  
        print("Creating job: ", serializer.data)  

        json_data = json.dumps(serializer.data)
        print("data: ", json.dumps(request.data))  
        #send_message(fully_qualified_namespace, dispatch_queue, serializer.data['task'])  
        send_message(fully_qualified_namespace, dispatch_queue, json_data)  
  
        headers = self.get_success_headers(serializer.data)  
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)  

    # delete method - we need to delete locally on the sqlite db and 
    # send a message to the delete queue in the service bus
    def destroy(self, request, *args, **kwargs):    
        instance = self.get_object()  
        serializer = self.get_serializer(instance)  
        json_data = json.dumps(serializer.data)
        send_message(fully_qualified_namespace, delete_queue, json_data)  
        self.perform_destroy(instance)  
        return Response(status=status.HTTP_204_NO_CONTENT)
  
    def perform_destroy(self, instance):  
        instance.delete()
  
def import_data(request):    
    try:  
        running_tasks = receive_messages(fully_qualified_namespace, running_queue)  
        for task in running_tasks:    
            json_data = json.loads(task)    
            task_name = json_data['task']    
            if not Job.objects.filter(task=task_name).exists():    
                job = Job(    
                    customer=json_data['customer'],    
                    task=task_name,    
                    np=json_data['np'],    
                    slots=json_data['slots'],    
                    simulation=json_data['simulation']    
                )      
                job.save()    
            else:    
                job = Job.objects.get(task=task_name)    
                job.delete()    
  
        message = {      
            "message": "Data imported successfully"      
        }   
    except Exception as e:  
        message = {  
            "message": "An error occurred while importing data",  
            "error": str(e)  
        }  
          
    return JsonResponse(message)