from rest_framework.routers import DefaultRouter
from .views import *
from django.urls import path, include

router = DefaultRouter()
router.register(r"jobs", JobViewset)

urlpatterns = [
    path("import/", import_data, name="import-jobs"),
    path("", include(router.urls))
]