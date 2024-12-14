> [Go to Home](../kubernetes-labs.md)

# Assignment No 3:

## Title: Kubernetes Commands

### 1. Setting Up Your Minikube Environment

Make sure Minikube is running. If it's not already started, open your terminal (Command Prompt or PowerShell on Windows) and start Minikube:

```bash
minikube start
```

### 2. Creating a Pod, Service, and Deployment

Let's start by creating the necessary YAML files for a Pod, Service, and Deployment.

**2.1. Create a Pod**
A **Pod** is the smallest deployable unit in Kubernetes. Let's create a simple Pod running an `nginx` web server.

1. Create a YAML file for the Pod:

Open a text editor and create a file named `nginx-pod.yaml` with the following content:

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: nginx-pod
    labels:
        app: nginx
spec:
    containers:
        - name: nginx
          image: nginx:latest
          ports:
              - containerPort: 80
```
