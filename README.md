# Django Blog Application Deployment Guide

This guide provides step-by-step instructions on how to deploy the Django blog application from the given repository to an online instance using Minikube with Kubernetes on a CIVO instance 
(CIVO is a Cloud Service Provider, You can use any other VM/local system) <br>
The deployment includes Dockerization, pod creation, scaling, and horizontal pod scaling.

<h2> Prerequisites:</h2>
<h3>Before you begin, ensure you have the following prerequisites:</h3>

1. A CIVO account with a medium instance for deployment. (You can choose any other CSP) <br>
2. Minikube installed on your local development machine. <br>
3. kubectl (Kubernetes command-line tool) installed. <br>
4. Docker installed.<br>
5. A Dockerized Django blog application.<br>
6. A Docker Hub account to push your Docker image (optional).<br>

<h2>Deployment Steps:</h2>

<h3>1. Clone the Repository</h3>
Clone the Grey-Scientific-Labs repository to your local machine:

```
git clone https://github.com/AbhayGRT/Grey-Scientific-Labs.git
cd Grey-Scientific-Labs
```

<h3>2. Dockerize Your Django Application:</h3>
Ensure your Django blog application is properly Dockerized. Create a Dockerfile in your project directory to define the Docker image. <br>
Example Dockerfile:

```
# Stage 1: Build environment
FROM python:3.8-slim-buster as builder

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create and set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt /app/

# Install project dependencies into a virtual environment
RUN python -m venv /venv
RUN /venv/bin/pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime environment
FROM python:3.8-slim-buster

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Create and set the working directory in the container
WORKDIR /app

# Copy the virtual environment from the builder stage
COPY --from=builder /venv /venv

# Copy the entire project directory into the container
COPY . /app/

# Expose the port your Django app will run on
EXPOSE 8000

# Start the Django development server
CMD ["/venv/bin/python", "manage.py", "runserver", "0.0.0.0:8000"]
```
 Build the Docker image:
```
docker build -t your-django-blog-image:tag .
```

<h3>3. Push Docker Image (Optional)</h3>
If you want to store your Docker image on Docker Hub or another container registry, tag and push the image:

```
docker login
docker tag your-django-blog-image:tag your-docker-hub-username/your-django-blog-image:tag
docker push your-docker-hub-username/your-django-blog-image:tag
```

<h3>4. Start Minikube Cluster</h3>
Start a Minikube cluster with appropriate resource allocation (CPU and memory):

```
minikube start --driver=docker
```

<h3>5. Create Kubernetes Deployment</h3>
Create a Kubernetes Deployment configuration (deployment.yaml) for your Django application. Define the number of replicas, Docker image, ports, and environment variables.
Example deployment.yaml:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: djangoblog-deployment
spec:
  replicas: 3  # Number of replicas you want to run
  selector:
    matchLabels:
      app: djangoblog
  template:
    metadata:
      labels:
        app: djangoblog
    spec:
      containers:
      - name: djangoblog
        image: abhaygrt/djanoblog:v1  # Your Docker image
        ports:
        - containerPort: 8000
```

Apply the deployment to your Minikube cluster:
  ```
kubectl apply -f deployment.yaml
```

<h3>6. Create Kubernetes Service</h3>
Create a Kubernetes Service configuration (service.yaml) to expose your Django application within the cluster. Use the LoadBalancer type for external access.
Example service.yaml:

```
apiVersion: v1
kind: Service
metadata:
  name: djangoblog-service
spec:
  selector:
    app: djangoblog
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: LoadBalancer
```

Apply the service to your Minikube cluster:

```
kubectl apply -f service.yaml
```

<h3>7. Horizontal Pod Autoscaling (Optional)</h3>
If needed, configure Horizontal Pod Autoscaling (HPA) based on resource utilization. Create an HPA resource (hpa.yaml) and apply it to your cluster.

```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: djangoblog-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: djangoblog-deployment
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
```

<h3>8. Access Your Deployed Application</h3>
Retrieve the external IP address of your Django application service:

```
http://your-instance-ip:8000
```
You have successfully deployed your Django blog application to an online instance using Minikube with Kubernetes on a CIVO/other instance.

