from django.db import models
from django.core.validators import MaxValueValidator, MinValueValidator
from .constants import SIMULATIONS
# Create your models here.

class Job(models.Model):
    customer = models.CharField(max_length=255)
    task = models.CharField(max_length=255)
    np = models.IntegerField(validators=[MinValueValidator(0),MaxValueValidator(280)])
    slots = models.IntegerField(validators=[MinValueValidator(0),MaxValueValidator(96)])
    simulation = models.CharField(max_length=10, choices = SIMULATIONS)

    def __str__(self):
        return self.customer