> [Go To home](../kubernetes-labs.md)

# Deployment

A Deployment manages a set of Pods to run an application workload, usually one that doesn't maintain state.

A **Deployment** provides declarative updates for Pods and ReplicaSets.

You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments.

> **NOTE**
>
> Do not manage ReplicaSets owned by a Deployment. Consider opening an issue in the main Kubernetes repository if your use case is not covered below.

## Create a Deployment

1. Create `firstdeployment.yml` file

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: firstdeployment
    labels:
        app: nginx
spec:
    replicas: 3
    selector:
        matchLabels:
            app: nginx
    template:
        metadata:
            name: dpod
            labels:
                app: nginx
        spec:
            containers:
                - name: container
                  image: nginx:1.26
                  ports:
                      - containerPort: 80

---
# Service for the above deployment

apiVersion: v1
kind: Service
metadata:
    name: firstservice
    labels:
        app: nginx
spec:
    type: NodePort
    selector:
        app: nginx
    ports:
        - port: 80
          targetPort: 80
          nodePort: 32000
```

Create a deployment and service

```bash
fish # kubectl apply -f firstdeploy.yml
deployment.apps/firstdeployment created
service/firstservice created

fish # kubectl get all -o wide
NAME                                   READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
pod/firstdeployment-7b5fd4f879-4nv8f   1/1     Running   0          17s   10.244.0.96   minikube   <none>           <none>
pod/firstdeployment-7b5fd4f879-jf6hf   1/1     Running   0          17s   10.244.0.94   minikube   <none>           <none>
pod/firstdeployment-7b5fd4f879-rgdbh   1/1     Running   0          17s   10.244.0.95   minikube   <none>           <none>

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE    SELECTOR
service/firstservice   NodePort    10.100.147.149   <none>        80:32000/TCP   17s    app=nginx
service/kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP        6d3h   <none>
service/my-service     NodePort    10.96.51.110     <none>        80:30007/TCP   15h    app=nginx

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES         SELECTOR
deployment.apps/firstdeployment   3/3     3            3           17s   container    nginx:stable   app=nginx

NAME                                         DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES         SELECTOR
replicaset.apps/firstdeployment-7b5fd4f879   3         3         3       17s   container    nginx:stable   app=nginx,pod-template-hash=7b5fd4f879
fish # kubectl get svc -o wide
NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE    SELECTOR
firstservice   NodePort    10.100.147.149   <none>        80:32000/TCP   89s    app=nginx
kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP        6d3h   <none>
my-service     NodePort    10.96.51.110     <none>        80:30007/TCP   15h    app=nginx
fish # kubectl get rs -o wide
NAME                         DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES         SELECTOR
firstdeployment-7b5fd4f879   3         3         3       106s   container    nginx:stable   app=nginx,pod-template-hash=7b5fd4f879

#here check the last field SELECTOR, it added the hash value "pod-template-hash"
fish # kubectl get pods -o wide --show-labels
NAME                               READY   STATUS    RESTARTS   AGE    IP            NODE       NOMINATED NODE   READINESS GATES   LABELS
firstdeployment-7b5fd4f879-4nv8f   1/1     Running   0          116s   10.244.0.96   minikube   <none>           <none>            app=nginx,pod-template-hash=7b5fd4f879
firstdeployment-7b5fd4f879-jf6hf   1/1     Running   0          116s   10.244.0.94   minikube   <none>           <none>            app=nginx,pod-template-hash=7b5fd4f879
firstdeployment-7b5fd4f879-rgdbh   1/1     Running   0          116s   10.244.0.95   minikube   <none>           <none>            app=nginx,pod-template-hash=7b5fd4f879
```

## Scale up and scale down

1. Open the `firstdeployment.yml` file

```bash
#change the line
spec:
  replicas: 5
###############
fish # kubectl apply -f firstdeploy.yml
deployment.apps/firstdeployment configured
service/firstservice unchanged
fish # kubectl get pods -o wide --show-labels
NAME                               READY   STATUS    RESTARTS   AGE     IP            NODE       NOMINATED NODE   READINESS GATES   LABELS
firstdeployment-7b5fd4f879-4nv8f   1/1     Running   0          4m59s   10.244.0.96   minikube   <none>           <none>            app=nginx,pod-template-hash=7b5fd4f879
firstdeployment-7b5fd4f879-hdpmg   1/1     Running   0          9s      10.244.0.97   minikube   <none>           <none>            app=nginx,pod-template-hash=7b5fd4f879
firstdeployment-7b5fd4f879-jf6hf   1/1     Running   0          4m59s   10.244.0.94   minikube   <none>           <none>            app=nginx,pod-template-hash=7b5fd4f879
firstdeployment-7b5fd4f879-jfdmr   1/1     Running   0          9s      10.244.0.98   minikube   <none>           <none>            app=nginx,pod-template-hash=7b5fd4f879
firstdeployment-7b5fd4f879-rgdbh   1/1     Running   0          4m59s   10.244.0.95   minikube   <none>           <none>            app=nginx,pod-template-hash=7b5fd4f879

###############
#change the line
spec:
  replicas: 2

###############
fish # kubectl apply -f firstdeploy.yml
deployment.apps/firstdeployment configured
service/firstservice unchanged
fish # kubectl get pods -o wide
NAME                               READY   STATUS    RESTARTS   AGE    IP            NODE       NOMINATED NODE   READINESS GATES
firstdeployment-7b5fd4f879-4nv8f   1/1     Running   0          6m1s   10.244.0.96   minikube   <none>           <none>
firstdeployment-7b5fd4f879-rgdbh   1/1     Running   0          6m1s   10.244.0.95   minikube   <none>           <none>
```

## Deployemnt Strategy

1. first change the version of nginx:

```yaml
# change the line:
  image: nginx:1.26
# to
  image: nginx:latest

# change the replicas
  replicas: 3
# To
  replicas: 5
```

```bash
fish # kubectl apply -f firstdeploy.yml; watch "kubectl get replicasets.apps -o wide"
deployment.apps/firstdeployment configured
service/firstservice unchanged

...
Every 2.0s: kubectl get replicasets.apps -o wide
mihirvp-81sy: Sat Nov 16 11:33:47 2024

NAME                         DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES         SELECTOR
firstdeployment-77996554dc   5         5         5       35s     container    nginx:latest   app=nginx,pod-template-hash=77996554dc
firstdeployment-7b5fd4f879   0         0         0       9m20s   container    nginx:stable   app=nginx,pod-template-hash=7b5fd4f879
```

you can monitor rollout using command in another terminal:

```bash
fish # kubectl rollout status deployment firstdeployment
deployment "firstdeployment" successfully rolled out
```

2. Create a new file called: `seconddeploy.yml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: seconddeployment
    labels:
        app: nginx
spec:
    selector:
        matchLabels:
            app: nginx
    replicas: 10
    minReadySeconds: 30
    strategy:
        rollingUpdate:
            maxSurge: 25%
            maxUnavailable: 25%
        type: RollingUpdate
    template:
        metadata:
            labels:
                app: nginx
        spec:
            containers:
                - name: MYAPP
                  image: nginx:latest
```

3 Important concepts:

In a Kubernetes Deployment, the parameters `minReadySeconds`, `minSurge`, and `maxUnavailable` are important for controlling how pods are managed during updates. These settings help balance the stability and availability of your application while ensuring smooth rollouts.

1. `minReadySeconds`

**Definition:** `minReadySeconds` specifies the minimum time a newly created pod must be in the "Ready" state before it’s considered available.

**Example:** If `minReadySeconds` is set to 10, the pod must remain in the Ready state for 10 seconds before it’s marked as available. This can prevent Kubernetes from marking a pod as ready prematurely.

2. `maxSurge`

**Definition:** `maxSurge` specifies the maximum number of pods that can be created above the desired replica count during an update.
**Purpose:** It provides extra capacity to handle traffic smoothly while older pods are being replaced with new ones.
**Value:** It can be set as an absolute number (e.g., `maxSurge: 2`) or as a percentage (e.g., `maxSurge: 25%` of the desired replica count).

3. `maxUnavailable`

**Definition:** `maxUnavailable` defines the maximum number of pods that can be unavailable during a rolling update. This allows Kubernetes to take down a certain number of old pods while new pods are being created.
**Value Type:** Can be an integer (number of pods) or a percentage (of the desired replica count).
**Purpose:** This setting provides control over availability during rollouts by limiting the number of pods that can be offline at any time.
**Example:** In a deployment with 5 replicas and maxUnavailable set to 1, only one pod can be taken offline while new pods are starting, ensuring that 4 pods are available at all times.

To see demo:

```bash
fish # kubectl get all -o wide
NAME                                   READY   STATUS    RESTARTS   AGE     IP             NODE       NOMINATED NODE   READINESS GATES
pod/firstdeployment-77996554dc-dnnwg   1/1     Running   0          15m     10.244.0.105   minikube   <none>           <none>
pod/firstdeployment-77996554dc-m4wd6   1/1     Running   0          15m     10.244.0.101   minikube   <none>           <none>
pod/firstdeployment-77996554dc-mwxv8   1/1     Running   0          15m     10.244.0.104   minikube   <none>           <none>
pod/firstdeployment-77996554dc-ts4xt   1/1     Running   0          15m     10.244.0.102   minikube   <none>           <none>
pod/firstdeployment-77996554dc-vszbq   1/1     Running   0          15m     10.244.0.103   minikube   <none>           <none>
pod/myapp-675ddc5df9-5gwhr             1/1     Running   0          4m25s   10.244.0.106   minikube   <none>           <none>
pod/myapp-675ddc5df9-5l9n6             0/1     Pending   0          4m25s   <none>         <none>     <none>           <none>
pod/myapp-675ddc5df9-6g5x7             0/1     Pending   0          4m25s   <none>         <none>     <none>           <none>
pod/myapp-675ddc5df9-9t4bf             0/1     Pending   0          4m25s   <none>         <none>     <none>           <none>
pod/myapp-675ddc5df9-dm8m9             0/1     Pending   0          4m25s   <none>         <none>     <none>           <none>
pod/myapp-675ddc5df9-gjpcw             0/1     Pending   0          4m25s   <none>         <none>     <none>           <none>
pod/myapp-675ddc5df9-mjwh9             0/1     Pending   0          4m25s   <none>         <none>     <none>           <none>
pod/myapp-675ddc5df9-q9jsz             0/1     Pending   0          4m25s   <none>         <none>     <none>           <none>
pod/myapp-675ddc5df9-s9jks             0/1     Pending   0          4m25s   <none>         <none>     <none>           <none>
pod/myapp-675ddc5df9-sx5mw             0/1     Pending   0          4m25s   <none>         <none>     <none>           <none>

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE    SELECTOR
service/firstservice   NodePort    10.100.147.149   <none>        80:32000/TCP   24m    app=nginx
service/kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP        6d3h   <none>
service/my-service     NodePort    10.96.51.110     <none>        80:30007/TCP   15h    app=nginx

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES         SELECTOR
deployment.apps/firstdeployment   5/5     5            5           24m     container    nginx:latest   app=nginx
deployment.apps/myapp             1/10    10           1           4m25s   myapp        nginx:latest   app=nginx

NAME                                         DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES         SELECTOR
replicaset.apps/firstdeployment-77996554dc   5         5         5       15m     container    nginx:latest   app=nginx,pod-template-hash=77996554dc
replicaset.apps/firstdeployment-7b5fd4f879   0         0         0       24m     container    nginx:stable   app=nginx,pod-template-hash=7b5fd4f879
replicaset.apps/myapp-675ddc5df9             10        10        1       4m25s   myapp        nginx:latest   app=nginx,pod-template-hash=675ddc5df9
```

```bash
#change the line
nginx:latest
#To
image: nginx:1.26
```

watch the output:

```bash
fish # kubectl apply -f seconddeploy.yml; watch "kubectl get rs -o wide"
deployment.apps/myapp configured

Every 2.0s: kubectl get rs -o wide
mihirvp-81sy: Sat Nov 16 12:00:28 2024

NAME                         DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES         SELECTOR
firstdeployment-77996554dc   5         5         5       27m     container    nginx:latest   app=nginx,pod-template-hash=77996554dc
firstdeployment-7b5fd4f879   0         0         0       36m     container    nginx:stable   app=nginx,pod-template-hash=7b5fd4f879
myapp-675ddc5df9             0         0         0       16m     myapp        nginx:latest   app=nginx,pod-template-hash=675ddc5df9
myapp-75456f5745             10        10        10      2m23s   myapp        nginx:stable   app=nginx,pod-template-hash=75456f5745
myapp-f68b54659              0         0         0       8m51s   myapp        nginx:stable   app=nginx,pod-template-hash=f68b54659

#in another terminal
fish # kubectl rollout status deployment myapp
deployment "myapp" successfully rolled out
```

## ROLLBACK

create a new yml file called `thirddeployment.yml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: thirddeployment
    labels:
        app: nginx
spec:
    replicas: 5
    selector:
        matchLabels:
            app: nginx
    template:
        metadata:
            name: dpod
            labels:
                app: nginx
        spec:
            containers:
                - name: container
                  image: nginx:1.26
                  ports:
                      - containerPort: 80
```

Create a deployment

```bash
fish # kubectl apply -f thirddeployment.yml
deployment.apps/thirddeployment configured
```

Interview Questions?

1. what is the default value of minReadySeconds, maxSurge and maxUnavailable, if not specified in the yml file??
   Anser:

```bash
kubectl describe deployments thirddeployment | less
```

and check the values of minReadySeconds, maxSurge and maxUnavailable. (its 0, 25% and 25%)

### kubectl rollout command

```bash
kubectl rollout
```

In Kubernetes, a rollback is a mechanism to revert a Deployment to a previous stable state if something goes wrong during an update or release. Rollbacks help maintain service availability and stability by quickly returning to a known working version of your application.

Here's a detailed explanation with an example.
Key Concepts in Rollback

1. **Revisions:** Every time a Deployment is updated (such as changing the container image, scaling the replica count, or modifying other specifications), Kubernetes creates a new "revision." Each revision is a snapshot of the Deployment at that point in time.
2. **Rollback:** If an update introduces issues (e.g., bugs, unexpected behavior), you can use the rollback feature to revert the Deployment to a previous revision.

Example Scenario: Deploying, Updating, and Rolling Back

Let's go through a step-by-step example to see how this works.

1. Step 1: Initial Deployment

Start by creating a Deployment with a specific image version.

```yaml
# app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: my-app
spec:
    replicas: 3
    selector:
        matchLabels:
            app: my-app
    template:
        metadata:
            labels:
                app: my-app
        spec:
            containers:
                - name: my-container
                  image: nginx:1.18
```

Apply this Deployment:

```bash
kubectl apply -f app-deployment.yaml
```

```bash
fish # kubectl get pods -o wide -l "app=my-deployment"
NAME                            READY   STATUS    RESTARTS   AGE     IP             NODE       NOMINATED NODE   READINESS GATES
my-deployment-d6674f5c9-ldrkn   1/1     Running   0          2m16s   10.244.0.124   minikube   <none>           <none>
my-deployment-d6674f5c9-nzqp7   1/1     Running   0          2m16s   10.244.0.123   minikube   <none>           <none>
my-deployment-d6674f5c9-t85v6   1/1     Running   0          2m16s   10.244.0.125   minikube   <none>           <none>
```

This creates a Deployment with nginx:1.18. Kubernetes assigns it a revision number 1.

2. Step 2: Update the Deployment

Now, let’s say you want to update the image to a newer version, nginx:1.19.

To update:

```yaml
# Update image to nginx:1.19
spec:
    template:
        spec:
            containers:
                - name: my-container
                  image: nginx:1.19
```

Apply the changes:

```bash
fish # kubectl apply -f mydeployment.yaml
deployment.apps/my-deployment configured
fish # kubectl get all -o wide -l "app=my-deployment"
NAME                                 READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
pod/my-deployment-7fc45cd79d-dmhd7   1/1     Running   0          31s   10.244.0.128   minikube   <none>           <none>
pod/my-deployment-7fc45cd79d-gnhp8   1/1     Running   0          33s   10.244.0.126   minikube   <none>           <none>
pod/my-deployment-7fc45cd79d-kxvvp   1/1     Running   0          32s   10.244.0.127   minikube   <none>           <none>

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS           IMAGES       SELECTOR
deployment.apps/my-deployment   3/3     3            3           3m30s   my-nginx-container   nginx:1.27   app=my-deployment

NAME                                       DESIRED   CURRENT   READY   AGE     CONTAINERS           IMAGES       SELECTOR
replicaset.apps/my-deployment-7fc45cd79d   3         3         3       33s     my-nginx-container   nginx:1.27   app=my-deployment,pod-template-hash=7fc45cd79d
replicaset.apps/my-deployment-d6674f5c9    0         0         0       3m30s   my-nginx-container   nginx:1.26   app=my-deployment,pod-template-hash=d6674f5c9
```

This triggers a rolling update, and Kubernetes creates a new revision 2. Now the Deployment is running nginx:1.19.
Step 3: Detecting an Issue

Suppose you notice that nginx:1.19 has a bug or unexpected behavior. To fix this, you decide to roll back to the previous working version (nginx:1.18).
Step 4: Performing the Rollback

To roll back to the previous revision, use the following command:

```bash
fish # kubectl rollout undo deployment my-deployment
deployment.apps/my-deployment rolled back

fish # kubectl get all -o wide -l "app=my-deployment"
NAME                                READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
pod/my-deployment-d6674f5c9-69d8b   1/1     Running   0          8s    10.244.0.130   minikube   <none>           <none>
pod/my-deployment-d6674f5c9-kbwzr   1/1     Running   0          7s    10.244.0.131   minikube   <none>           <none>
pod/my-deployment-d6674f5c9-xbc5w   1/1     Running   0          10s   10.244.0.129   minikube   <none>           <none>

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS           IMAGES       SELECTOR
deployment.apps/my-deployment   3/3     3            3           5m11s   my-nginx-container   nginx:1.26   app=my-deployment

NAME                                       DESIRED   CURRENT   READY   AGE     CONTAINERS           IMAGES       SELECTOR
replicaset.apps/my-deployment-7fc45cd79d   0         0         0       2m14s   my-nginx-container   nginx:1.27   app=my-deployment,pod-template-hash=7fc45cd79d
replicaset.apps/my-deployment-d6674f5c9    3         3         3       5m11s   my-nginx-container   nginx:1.26   app=my-deployment,pod-template-hash=d6674f5c9
```

This command will:

-   Revert the Deployment to the most recent previous revision (revision 1).
-   Replace all nginx:1.19 pods with nginx:1.18 pods.

Kubernetes handles this rollback as a rolling update, ensuring that the application stays available during the transition.

Step 5: Verifying the Rollback

You can verify that the rollback occurred and which version is running by checking the deployment history:

```bash
fish # kubectl rollout history deployment/my-deployment
deployment.apps/my-deployment
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
```

The output will show the revisions, including the one currently active.
Step 6: Rolling Back to a Specific Revision

If you need to roll back to a specific revision, you can specify it explicitly. For example:

```bash
fish # kubectl rollout undo deployment/my-deployment --to-revision 2
deployment.apps/my-deployment rolled back

fish # kubectl get all -o wide -l "app=my-deployment"
NAME                                 READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
pod/my-deployment-7fc45cd79d-fkv8d   1/1     Running   0          9s    10.244.0.133   minikube   <none>           <none>
pod/my-deployment-7fc45cd79d-pn9pk   1/1     Running   0          6s    10.244.0.134   minikube   <none>           <none>
pod/my-deployment-7fc45cd79d-tdpnp   1/1     Running   0          10s   10.244.0.132   minikube   <none>           <none>

NAME                            READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS           IMAGES       SELECTOR
deployment.apps/my-deployment   3/3     3            3           8m13s   my-nginx-container   nginx:1.27   app=my-deployment

NAME                                       DESIRED   CURRENT   READY   AGE     CONTAINERS           IMAGES       SELECTOR
replicaset.apps/my-deployment-7fc45cd79d   3         3         3       5m16s   my-nginx-container   nginx:1.27   app=my-deployment,pod-template-hash=7fc45cd79d
replicaset.apps/my-deployment-d6674f5c9    0         0         0       8m13s   my-nginx-container   nginx:1.26   app=my-deployment,pod-template-hash=d6674f5c9
```

This command will roll back to revision 1, regardless of any other intermediate revisions.

### Important Commands for Rollbacks

-   Undo the last rollout:

```bash
$ kubectl rollout undo deployment/my-app
```

-   Rollback to a specific revision:

```bash
$ kubectl rollout undo deployment/my-app --to-revision=<revision-number>
```

-   View deployment history:

```bash
$ kubectl rollout history deployment/my-app
```

-   Check status of the rollout:

```bash
$ kubectl rollout status deployment/my-app
```

#### Cleanup

-   Remove all deployments and services

```bash
fish # kubectl delete deployments.apps --all
deployment.apps "firstdeployment" deleted
deployment.apps "my-deployment" deleted
deployment.apps "myapp" deleted
deployment.apps "mydeployment" deleted
deployment.apps "thirddeployment" deleted

fish # kubectl delete service firstservice my-service
service "firstservice" deleted
service "my-service" deleted
```
