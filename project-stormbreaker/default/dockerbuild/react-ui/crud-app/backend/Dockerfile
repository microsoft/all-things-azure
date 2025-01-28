# Use the official Python base image
FROM python:3.10

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY . .

# Generate a random secret key using OpenSSL and set it as an environment variable  
RUN SECRET_KEY=$(openssl rand -hex 32) && \  
    echo "export SECRET_KEY=$SECRET_KEY" >> /etc/profile && \  
    echo "export SECRET_KEY=$SECRET_KEY" >> ~/.bashrc && \  
    export SECRET_KEY=$SECRET_KEY  

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Migrate the database
RUN python manage.py makemigrations \
    && python manage.py migrate

# Expose the port on which the Django app will run
EXPOSE 8000

# Start the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
