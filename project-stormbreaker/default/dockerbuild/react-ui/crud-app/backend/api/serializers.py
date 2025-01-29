from rest_framework.serializers import ModelSerializer
from .models import Job

class JobSerializer(ModelSerializer):
    class Meta:
        model = Job
        fields = '__all__'


from rest_framework import viewsets  
  
class MyModelViewSet(viewsets.ModelViewSet):  
    # queryset, serializer_class here  
  
    def destroy(self, request, *args, **kwargs):  
        instance = self.get_object()  
  
        # Perform any checks here.  
        if not can_delete(instance):  
            return Response({"error": "You can't delete this"}, status=400)  
  
        self.perform_destroy(instance)  
        return Response(status=204)