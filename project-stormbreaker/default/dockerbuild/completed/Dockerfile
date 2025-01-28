# az acr build  -t misc/servicebus-dispatcher:1.0 -r stormbreakeracrdc.azurecr.io .
# Use an official Python runtime as a parent image
FROM python:3.8

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv ./kubectl /usr/local/bin

RUN apt update && apt install -y sqlite3

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Run servicebus_remover.py when the container launches
CMD ["python", "./servicebus_remover.py"]
