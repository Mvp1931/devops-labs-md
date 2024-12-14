# Service:

## How to access the Nginx service running inside the pod from outside

-   Expose an application running in your cluster behind a single outward-facing endpoint, even when the workload is split across multiple backends.
-   In Kubernetes, a `Service` is a method for exposing a network application that is running as one or more Pods in your cluster.

-   The set of Pods targeted by a Service is usually determined by a `selector` that you define.

## Defining a Service

A Service is an object (the same way that a Pod or a ConfigMap is an object). You can create, view or modify Service definitions using the Kubernetes API. Usually you use a tool such as kubectl to make those API calls for you.

For example, suppose you have a set of Pods that each listen on TCP port 9376 and are labelled as app.kubernetes.io/name=MyApp. You can define a Service to publish that TCP listener:

```yaml
apiVersion: v1
kind: Service
metadata:
    name: my-service
spec:
    selector:
        app.kubernetes.io/name: MyApp
    ports:
        - protocol: TCP
          port: 80
          targetPort: 9376
```

Applying this manifest creates a new Service named "my-service" with the default ClusterIP service type. The Service targets TCP port 9376 on any Pod with the app.kubernetes.io/name: MyApp label.

> **_NOTE:_** :A Service can map any incoming port to a targetPort. By default and for convenience, the targetPort is set to the same value as the port field.

## Example of Service

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: nginx
    labels:
        app.kubernetes.io/name: proxy
spec:
    containers:
        - name: nginx
          image: nginx:stable
          ports:
              - containerPort: 80
                name: http-web-svc

---
apiVersion: v1
kind: Service
metadata:
    name: nginx-service
spec:
    selector:
        app.kubernetes.io/name: proxy
    ports:
        - name: name-of-service-port
          protocol: TCP
          port: 80
          targetPort: http-web-svc
```

## Service type

For some parts of your application (for example, frontends) you may want to expose a Service onto an external IP address, one that's accessible from outside of your cluster.

Kubernetes Service types allow you to specify what kind of Service you want.

The available type values and their behaviors are:

1. **ClusterIP:**
   **Exposes the Service on a cluster-internal IP.** Choosing this value makes the Service only reachable from within the cluster. This is the default that is used if you don't explicitly specify a type for a Service. You can expose the Service to the public internet using an Ingress or a Gateway.

2. **NodePort**
   **Exposes the Service on each Node's IP at a static port (the NodePort).** To make the node port available, Kubernetes sets up a cluster IP address, the same as if you had requested a Service of type: ClusterIP.

3. **LoadBalancer**
   Exposes the Service externally using an external load balancer. Kubernetes does not directly offer a load balancing component; you must provide one, or you can integrate your Kubernetes cluster with a cloud provider.

4. **ExternalName**
   Maps the Service to the contents of the externalName field (for example, to the hostname api.foo.bar.example). The mapping configures your cluster's DNS server to return a CNAME record with that external hostname value. No proxying of any kind is set up.

The `type` field in the Service API is designed as nested functionality - each level adds to the previous. However there is an exception to this nested design. You can define a LoadBalancer Service by disabling the load balancer NodePort allocation

---

# DEMO of Service - ClusterIP

#### Create a `clusterIp_Demo.yml` file.

```yaml
apiVersion: v1
kind: pod
metadata:
    name: firstpod
    labels:
        app: nginx
spec:
    containers:
        - name: firstcontainer
          image: nginx:latest
```

1. Create a Pod

```bash
fish # kubectl apply -f testpod.yaml
pod/firstpod created
fish # kubectl get pods -o wide
NAME       READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
firstpod   1/1     Running   0          10s   10.244.0.136   minikube   <none>           <none>
```

Now the pod is created and nginx service is running inside the pods at port 80. But, how to access it?

## Create a service using imperative command

```bash
kubectl expose pod firstpod --port=8080 --target-port=80 --name myfirstservice

kubectl get svc
```

Test the nginx service but, you must be inside the cluster as clusterIp cann't be access outside the cluster:

## Test Connectivity from Inside the Cluster

Since ClusterIP services are internal, you need to run curl from within a Pod that is inside the cluster. If you are trying curl from your local machine, it won't work.

You can test it from the same firstpod by running:

```bash
fish # kubectl exec -it firstpod -- /bin/bash
root@firstpod:/#
```

Once inside the Pod, try running:

```bash
root@firstpod:/# curl 10.100.252.71:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
root@firstpod:/#
```

A ClusterIP service is only accessible from within the cluster—this is the primary limitation of a ClusterIP type service in Kubernetes. That's why you're able to curl the service from inside the Pod but not from outside the cluster.

If you want to test your service from outside the cluster, you will need to change the service type from ClusterIP to a type that is accessible externally. Here are two common ways to expose your service externally:

## 1. Change the Service Type to NodePort

The `NodePort` service type exposes the service on a specific port of each Node in the cluster, allowing you to access it from outside the cluster.

You can expose the service using the NodePort type with the following command:

```bash
fish # kubectl expose pod firstpod --type NodePort --port 8080 --target-port 80 --name=mysecondservice
service/mysecondservice exposed
fish # kubectl get services
NAME              TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
kubernetes        ClusterIP   10.96.0.1        <none>        443/TCP          6d6h
myfirstservice    ClusterIP   10.100.252.71    <none>        8080/TCP         18m
mysecondservice   NodePort    10.102.204.199   <none>        8080:32299/TCP   3s
```

## 2. How to access the NodePort service in Minikube:

_Steps_:

1. Get the Minikube IP by running:

```bash
minikube ip
```

This will return something like `192.168.99.100`.

2. Access the service using the Minikube IP and NodePort:

Since the NodePort assigned is 32087, you can now test it using the following command:

```bash
curl <minikube-ip>:32087

for example:
curl 192.168.99.100:32087
```

if you check the command:

```bash
curl 192.168.99.100:8080
```

will not work as the type of service is ClusterIp

delete the pods

```bash
fish # kubectl delete pods firstpod
pod "firstpod" deleted
fish # kubectl delete service myfirstservice
service "myfirstservice" deleted
fish # kubectl delete service mysecondservice
service "mysecondservice" deleted
```

---

# Kubernetes Service Demo - ClusterIP

```yaml
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
    name: nginx-deployment
spec:
    replicas: 2
    selector:
        matchLabels:
            app: nginx
    template:
        metadata:
            labels:
                app: nginx
        spec:
            containers:
                - name: nginx-container
                  image: nginx:latest
                  ports:
                      - containerPort: 80

---
# Service (ClusterIP)
apiVersion: v1
kind: Service
metadata:
    name: nginx-service
spec:
    type: ClusterIP
    selector:
        app: nginx
    ports:
        - protocol: TCP
          port: 8080
          targetPort: 80
```

## Test the service

```bash
kubectl apply -f 1_clusterIp_Demo.yml
kubectl get svc
```

## Access the Service

To test the service, you can use the following command to open a temporary Pod and use curl to access the service inside the cluster:

```bash
fish # kubectl get all
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-6f88c56d9f-lbfcg   1/1     Running   0          32s
pod/nginx-deployment-6f88c56d9f-lzqdf   1/1     Running   0          32s

NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP    6d7h
service/nginx-service   ClusterIP   10.111.126.34   <none>        8080/TCP   32s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment   2/2     2            2           32s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deployment-6f88c56d9f   2         2         2       32s
fish # minikube ssh
docker@minikube:~$

# OR
kubectl run curl --image=curlimages/curl -i --tty -- /bin/sh
```

Inside the temporary Pod, run:

```bash
docker@minikube:~$ curl 10.111.126.34:8080
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
docker@minikube:~$
```

You should see the NGINX default page HTML as output.

---

# Kubernets Service Demo - NodePort

-   step 1: Visit the link to copy the deployment: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: nginx-deployment
    labels:
        app: nginx
spec:
    replicas: 2
    selector:
        matchLabels:
            app: nginx
    template:
        metadata:
            labels:
                app: nginx
        spec:
            containers:
                - name: nginx
                  image: nginx:1.14.2
                  ports:
                      - containerPort: 80
```

-   step 2: Visit the link to copy the service: https://kubernetes.io/docs/concepts/services-networking/service/

```yaml
apiVersion: v1
kind: Service
metadata:
    name: my-service
spec:
    type: NodePort
    selector:
        app: nginx
    ports:
        - port: 80
          targetPort: 80
          nodePort: 30007 # You can choose a port in the range 30000-32767
```

Apply this

```bash
fish # kubectl apply -f 2_NodePort_Demo.yml
deployment.apps/nginx-deployment configured
service/my-service created
fish # kubectl get service
NAME            TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes      ClusterIP   10.96.0.1       <none>        443/TCP        6d8h
my-service      NodePort    10.108.42.175   <none>        80:30007/TCP   7s
nginx-service   ClusterIP   10.111.126.34   <none>        8080/TCP       14m
```

## Accessing the NodePort Service

```bash
minikube ip
```

Now access it in the browser using the Minikube IP and NodePort (e.g., http://<minikube-ip>:30007).

You should see the NGINX welcome page.

---

# Kubernets Service Demo - LoadBalancer

If you are using a cloud provider like GKE/AKS/EKS, you can create a LoadBalancer service to expose it externally.

```yaml
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
    name: nginx-deployment
spec:
    replicas: 2
    selector:
        matchLabels:
            app: nginx
    template:
        metadata:
            labels:
                app: nginx
        spec:
            containers:
                - name: nginx-container
                  image: nginx:latest
                  ports:
                      - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
    name: nginx-service-loadbalancer
spec:
    type: LoadBalancer
    selector:
        app: nginx
    ports:
        - protocol: TCP
          port: 80
          targetPort: 80
```

Apply the service:

```bash
fish # kubectl apply -f 3_LoadBalancer.yml
deployment.apps/nginx-deployment configured
service/nginx-service-loadbalancer created

fish # kubectl get svc
NAME                         TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
kubernetes                   ClusterIP      10.96.0.1        <none>        443/TCP          6d8h
my-service                   NodePort       10.103.163.206   <none>        8080:30007/TCP   2m53s
nginx-service-loadbalancer   LoadBalancer   10.105.36.158    127.0.0.1     80:30785/TCP     109s
```

Once the external IP is assigned, you can access it via the browser.

---

-   Clean up the resources.

```bash
fish # kubectl delete service my-service
service "my-service" deleted
fish # kubectl delete service nginx-service-loadbalancer
service "nginx-service-loadbalancer" deleted
fish # kubectl get all
NAME                                    READY   STATUS    RESTARTS   AGE
pod/curl                                1/1     Running   0          25m
pod/nginx-deployment-6f88c56d9f-p6dnr   1/1     Running   0          2m50s
pod/nginx-deployment-6f88c56d9f-sxbc5   1/1     Running   0          2m56s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   6d8h

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment   2/2     2            2           28m

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-deployment-6bc9464669   0         0         0       14m
replicaset.apps/nginx-deployment-6f88c56d9f   2         2         2       28m
fish # kubectl delete deployments.apps nginx-deployment
deployment.apps "nginx-deployment" deleted
```
