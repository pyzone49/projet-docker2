<div align="left">
  <h1>Academix Project</h1>
  <p>Developed by <strong>Yacine FLICI</strong></p>
  <p>Developed by <strong>Tilelli Bektache</strong></p>
  <p>Contact: <a href="mailto:yacineflici2@gmail.com">yacineflici2@gmail.com</a>
   <a href="mailto:tilelli.bektache@etu.u-paris.fr">tilelli.bektache@etu.u-paris.fr</a>
  </p>
</div>

This project demonstrates the deployment of a web service using Docker, Kubernetes, and Istio for service mesh integration. The service is developed, containerized, and deployed on a Kubernetes cluster, followed by setting up a service mesh with Istio. This README provides a step-by-step guide to the project's implementation.

## Table of Contents
1. [Project Setup](#project-setup)
2. [Build the Docker Image and Run the Container](#2-build-the-docker-image-and-run-the-container)
3. [Push the Docker Image to Docker Hub](#3-push-the-docker-image-to-docker-hub)
4. [Create a Deployment and Service in Kubernetes](#4-create-a-deployment-and-service-in-kubernetes)
5. [Create Gateway and Virtual Service for Istio](#5-create-gateway-and-virtual-service-for-istio)
6. [Apply the Configuration Files and Verify the Deployments](#6-apply-the-configuration-files-and-verify-the-deployments)
7. [Access the Web Service](#7-access-the-web-service)

## Project Setup
### 1. Start Minikube
```sh
minikube start
```

### 2.  Build the Docker Image and Run the Container
#### 2.1 Frontend Web Service (From our other subject (web development))
This Dockerfile sets up a containerized environment for a Python web application.

- **Base Image:** Uses Python 3.12.3 as the base image.
- **Working Directory:** Sets the working directory in the container to the current directory.
- **Copy Files:** Copies all the contents of the current directory on the host machine into the container.
- **Environment Variable:** Sets the environment variable `PYTHONUNBUFFERED` to `1` to ensure output is not buffered.
- **Copy Requirements:** Copies the `requirements.txt` file into the container.
- **Install Dependencies:** Installs the Python packages listed in `requirements.txt`.
- **Command:** Defines the command to run the application: `python3 manage.py runserver 0.0.0.0:8000`, which starts the Django development server and makes it accessible on port 8000.

This Dockerfile sets up a Python environment, installs dependencies, and runs a Django web server.

#### 2.2 Backend API
This Dockerfile sets up a containerized environment for a Python application.

- **Base Image:** Uses Python 3.12.3 as the base image.
- **Working Directory:** Sets the working directory in the container to the current directory.
- **Copy Files:** Copies all the contents of the current directory on the host machine into the container.
- **Environment Variable:** Sets the environment variable `PYTHONUNBUFFERED` to `1` to ensure output is not buffered.
- **Copy Requirements:** Copies the `requirements.txt` file into the container.
- **Install Dependencies:** Installs the Python packages listed in `requirements.txt`.
- **Command:** Defines the command to run the application: `python3 app.py`, which starts the application using `app.py`.

This Dockerfile sets up a Python environment, installs dependencies, and runs a Python application script.
```sh
docker build -t academix-project .
docker run -p 8000:8000 academix-project
```
Screenshot of browser output:
<p align="center"> <img src='./screenshots/Screenshot%202024-05-19%20at%2012.04.38.png' align="center" width="100%"> </p>

### 3.  Push the Docker Image to Docker Hub
```sh
docker tag academix-project pyzone49/academix_project:1
docker push pyzone49/academix_project:1
```
Backend API Docker Image:
```sh
docker tag academix-api pyzone49/academix_api:2
docker push pyzone49/academix_api:2
```
Screenshot of Docker Hub:
<p align="center"> <img src='./screenshots/Screenshot 2024-05-19 at 12.09.41.png' align="center" width="100%"> </p>

### 4.  Create a Deployment and Service in Kubernetes
Using the YAML files provided in the repository, create a deployment and service for the frontend web service and backend API.


#### 4.1 [api.yaml](./api.yaml)

This YAML configuration creates a Kubernetes Deployment and Service for the backend API called `academix-api`, and connects it to a MySQL database service. 

**Deployment:**
- The Deployment, named `flask-api-deployment` and located in the `production` namespace, manages a single replica of the `flask-api` pod.
- The pod uses the Docker image `pyzone49/academix_api:2` and listens on port 5000.
- Environment variables are set to configure the connection to a MySQL database, including the host, port, database name, user, and password.
- The restart policy is set to always restart the container if it fails.

**Service:**
- The Service, named `flask-api-service` and also in the `production` namespace, is of type `ClusterIP`.
- It exposes the `flask-api` pod on port 5000 and routes traffic to the container's port 5000.
- The Service uses a label selector to route traffic to the appropriate pod with the label `app: flask-api`.

This setup ensures that the `academix-api` backend is deployed with a single replica in the `production` namespace and is connected to a MySQL database. The `ClusterIP` Service exposes the API internally within the Kubernetes cluster on port 5000, making it accessible to other services within the cluster.

#### 4.2 [deployment.yaml](./deployment.yaml) and [service.yaml](./service.yaml)

This YAML configuration creates a Kubernetes Deployment and Service for the frontend web service called `academix-project`.

**Deployment:**
- The Deployment, named `academix-deployment` and located in the `production` namespace, manages a single replica of the `academix-service` pod.
- The pod uses the Docker image `pyzone49/academix_project:1` and listens on port 8000.
- The `imagePullPolicy` is set to `IfNotPresent`, ensuring that the image is pulled only if it's not already present locally.
- The pod is labeled with `app: academix-service`, and the Deployment uses this label to identify and manage the pod.
- The restart policy is set to always restart the container if it fails.

**Service:**
- The Service, named `academix-service` and also in the `production` namespace, is of type `ClusterIP`.
- It exposes the `academix-service` pod on port 8000 and routes traffic to the container's port 8000.
- The Service uses a label selector to route traffic to the appropriate pod with the label `app: academix-service`.

This setup ensures that the `academix-project` frontend web service is deployed with a single replica in the `production` namespace. The `ClusterIP` Service exposes the web service internally within the Kubernetes cluster on port 8000, making it accessible to other services within the cluster.


#### 4.3 [db_deployment.yaml](./db_deployment.yaml) 
This would create a deployment for a MySQL database called `academixdb`.
#### 4.3.1 Persistent Volume Claim
First, we need to create a Persistent Volume Claim (PVC) to provide storage for our MySQL database.
#### 4.3.2 MySQL Deployment
Next, we create a deployment for the MySQL database. This deployment includes environment variables for setting up the database, user, and password, and it mounts the PVC created earlier.
#### 4.3.3 MySQL Service
Finally, we create a service for the MySQL database to allow communication between the backend service and the database.

By following these steps, the MySQL database is deployed and accessible within the Kubernetes cluster. The web service can now connect to this database using the provided environment variables.


### 5.  Create Gateway and Virtual Service for Istio
Using the YAML files provided in the repository, create a gateway and virtual service for the frontend web service and backend API.


#### 5.1 Install Istio
```sh
export PATH=$PWD/bin:$PATH
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled
```
and before that we make sure to start minikube tunnel:
```sh
minikube tunnel
```
This will allow us to access the services from the browser.
#### 5.2 Create Gateway 
Using [infrastucture.yaml](./infrastucture.yaml) file, create a gateway for the frontend web service and backend API.
THis will create a gateway called `academix-gateway` and attach it to the frontend web service and backend API.
Following this architecture:
<p align="center"> <img src='./screenshots/Screenshot 2024-05-19 at 12.32.50.png' align="center" width="100%"> </p>

#### 5.3 Create Virtual Service
Using [microservices.yaml](./microservices.yaml) file, create a virtual service for the frontend web service and backend API.
This will create a virtual service called `academix-virtual` and attach it to the frontend web service and backend API.

This document explains the configuration of virtual services as defined in the provided YAML file. The file configures routes for different URIs to specific backend services.
##### HTTP Routing Rules

##### 1. `/contact`

- **match prefix**: `/contact`
- **host service**: `academix-service`

##### 2. `/about`

- **match prefix**: `/about`
- **host service**: `academix-service`

##### 3. `/formations`

- **match prefix**: `/formations`
- **host service**: `academix-service`

##### 4. `/admin`

- **match prefix**: `/admin`
- **host service**: `academix-service`

##### 5. `/home`

- **match prefix**: `/home`
- **host service**: `academix-service`

##### 6. `/data`

- **match prefix**: `/data`
- **host service**: `flask-api-service`




### 6. Apply the Configuration Files and Verify the Deployments
```sh
./apply.sh
```

#### 6.1 Verify Deployments and Services
```sh
./check_setup.sh
```
<p align="center"> <img src='./screenshots/Screenshot 2024-05-19 at 13.09.35.png' align="center" width="100%"> </p>


#### 6.2 Verify Istio Routing Rules
```sh
istioctl proxy-config routes istio-ingressgateway-podname -n istio-system
```
<p align="center"> <img src='./screenshots/Screenshot 2024-05-19 at 13.18.09.png' align="center" width="100%"> </p>

### 7. Access the Web Service
```sh
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```
<p align="center"> <img src='./screenshots/Screenshot 2024-05-19 at 13.19.04.png' align="center" width="100%"> </p>

# Google Labs

Here is the scores of the labs:

- ## Yacine FLICI
<img width="1153" alt="YACINE" src="https://github.com/pyzone49/projet-docker2/assets/152429992/fb83242f-1e6b-425a-a9f9-3af5876112d1">


- ## Tilelli BEKTACHE
![Capture d'écran 2024-05-19 134831](https://github.com/pyzone49/projet-docker2/assets/152429992/60b79033-b038-40c6-a01d-da19ad724947)

For this lab, I experienced internet issues and clicked unintentionally:
![Capture d'écran 2024-05-19 140402](https://github.com/pyzone49/projet-docker2/assets/152429992/f8689795-6c00-44e2-8417-fa4561f5ed23)

