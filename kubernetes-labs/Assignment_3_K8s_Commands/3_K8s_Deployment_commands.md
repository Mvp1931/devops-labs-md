> [Go To home](../kubernetes-labs.md)

# Assignment 3 C

## Title: Deployment commands

### 1. Introduction to Deployments

Start by explaining what a Deployment is in Kubernetes:

-   A Deployment is a Kubernetes resource that provides declarative updates for Pods and ReplicaSets.
-   It helps automate the process of deploying, scaling, and managing containerized applications.
-   Deployments ensure that a specified number of Pods are running and can perform rolling updates, rollbacks, and scaling.

### 2. Basic kubectl Commands for Deployments

Explain the most commonly used kubectl commands related to Deployments and provide hands-on examples for each.

**2.1.Imperative command**

_**Create a deployment named my-dep that runs the nginx image with 3 replicas**_

```bash
kubectl create deployment my-dep --image=nginx --replicas=3
```

```sh
fish # kubectl create deployment my-deployment --image nginx:latest --replicas 3
deployment.apps/my-deployment created
fish # kubectl get deployment
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
my-deployment   3/3     3            3           15s
```

**2.2.Creating a Deployment**

Command: `kubectl apply -f <file>`

This command applies a YAML configuration file that defines a Deployment.

**Example YAML for Deployment: `nginx-deployment.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: nginx-deployment
spec:
    replicas: 3
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
                  image: nginx:latest
                  ports:
                      - containerPort: 80
```

Run the command:

```bash
kubectl apply -f nginx-deployment.yaml
```

```bash
fish # kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment created
```

**Verification Command: kubectl get deployments**

Run

```bash
$ kubectl get deployments

NAME               READY   UP-TO-DATE   AVAILABLE   AGE
my-deployment      3/3     3            3           2m51s
nginx-deployment   3/3     3            3           64s
```

This command lists all Deployments in the default namespace. Students should see the nginx-deployment listed with 3 replicas.

**2.3. Viewing and Describing a Deployment**

Command: `kubectl describe deployment <deployment-name>`
This command provides detailed information about a Deployment, including its status, events, and configurations.

```bash
$ kubectl describe deployment nginx-deployment

fish # kubectl describe deployment nginx-deployment > deployment-info
fish # cat deployment-info
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Fri, 15 Nov 2024 14:31:39 +0530
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:      nginx:latest
    Port:       80/TCP
    Host Port:  0/TCP
    Limits:
      cpu:         500m
      memory:      128Mi
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-7d85d66c99 (3/3 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  2m5s  deployment-controller  Scaled up replica set nginx-deployment-7d85d66c99 to 3
```

Will display details about the nginx-deployment, including the number of replicas, current status, strategy, and any events associated with it.

**2.4. Updating a Deployment**
Change the number of replicas from `3` to `5` in `nginx-deployment.yaml`:

```yaml
---
spec:
    replicas: 5
```

```bash
$ kubectl apply -f nginx-deployment.yaml

fish # kubectl apply -f nginx-deployment.yaml
deployment.apps/nginx-deployment configured
```

check the updated Deployment

```bash
$ kubectl get deployments

fish # kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
my-deployment      3/3     3            3           5m56s
nginx-deployment   5/5     5            5           4m9s
```

The output should now show 5 replicas for `nginx-deployment`.

**2.4. Scaling a Deployment**
Command: `kubectl scale deployment <deployment-name> --replicas=<number>`

Explain that kubectl scale allows you to quickly change the number of replicas of a Deployment without modifying the YAML file.

```bash
kubectl scale deployment nginx-deployment --replicas=2
```

This command will Scale the nginx-deployment to 2 replicas:
Verify the scaling:

```bash
$ kubectl get deployments
$ kubectl get pods

fish # kubectl scale deployment nginx-deployment --replicas 2
deployment.apps/nginx-deployment scaled

fish # kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
my-deployment      3/3     3            3           8m35s
nginx-deployment   2/2     2            2           6m48s

fish # kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
my-deployment-5c84f9f74-2jgqz       1/1     Running   0          8m56s
my-deployment-5c84f9f74-7hw98       1/1     Running   0          8m56s
my-deployment-5c84f9f74-tsptx       1/1     Running   0          8m56s
nginx-deployment-7d85d66c99-btm6x   1/1     Running   0          7m9s
nginx-deployment-7d85d66c99-c75vh   1/1     Running   0          7m9s
```

The `nginx-deployment` should now have 2 replicas.

**2.5. Rolling Update of a Deployment**

Command: `kubectl set image deployment/<deployment-name> <container-name>=<new-image>`

Explain that kubectl set image is used to perform a rolling update by changing the image version of a container in a Deployment.

-   Update the nginx container image to version 1.19.0:

(_Note: Here, I will switch to stable version of nginx image, which is nginx:1.26.2, from the latest version, nginx:latest or nginx:1.27.2_)

```bash
$ kubectl set image deployment/nginx-deployment nginx=nginx:stable

fish # kubectl set image deployment/nginx-deployment nginx=nginx:stable
deployment.apps/nginx-deployment image updated
```

Verify the update:

```bash
$ kubectl rollout status deployment/nginx-deployment
$ kubectl get pods

fish # kubectl rollout status deployment/nginx-deployment
deployment "nginx-deployment" successfully rolled out
fish # kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
my-deployment-5c84f9f74-2jgqz      1/1     Running   0          13m
my-deployment-5c84f9f74-7hw98      1/1     Running   0          13m
my-deployment-5c84f9f74-tsptx      1/1     Running   0          13m
nginx-deployment-cf696664c-8c87j   1/1     Running   0          54s
nginx-deployment-cf696664c-ztdwb   1/1     Running   0          36s

# as you can see here UUID for new nginx-deployment-... is different from previous one
```

The Pods should gradually be updated to use the new image.

**2.6. Rollback a Deployment**

Command: `kubectl rollout undo deployment/<deployment-name>`
Explain that kubectl rollout undo is used to roll back to the previous revision in case the new update causes issues.

-   Roll back the nginx-deployment to the previous version:

```bash
kubectl rollout undo deployment/nginx-deployment
```

-   Verify the rollback:

```bash
$ kubectl describe deployment nginx-deployment
$ kubectl get pods

fish # kubectl rollout undo deployment/nginx-deployment
deployment.apps/nginx-deployment rolled back
fish # kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
my-deployment-5c84f9f74-2jgqz       1/1     Running   0          47m
my-deployment-5c84f9f74-7hw98       1/1     Running   0          47m
my-deployment-5c84f9f74-tsptx       1/1     Running   0          47m
nginx-deployment-7d85d66c99-bn4jh   1/1     Running   0          24s
nginx-deployment-7d85d66c99-krbgr   1/1     Running   0          29s
```

The Pods should roll back to the previous image version.

**2.7. Deleting a Deployment**

Command: `kubectl delete deployment <deployment-name>`
This command deletes the specified Deployment and all the Pods managed by it.

-   Delete the nginx-deployment:

```bash
$ kubectl delete deployment nginx-deployment

fish # kubectl delete deployment nginx-deployment
deployment.apps "nginx-deployment" deleted
```

-   Verify that the Deployment and Pods are deleted:

```bash
$ kubectl get deployments
$ kubectl get pods

fish # kubectl get deployments
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
my-deployment   3/3     3            3           48m
fish # kubectl get pods
NAME                            READY   STATUS    RESTARTS   AGE
my-deployment-5c84f9f74-2jgqz   1/1     Running   0          48m
my-deployment-5c84f9f74-7hw98   1/1     Running   0          48m
my-deployment-5c84f9f74-tsptx   1/1     Running   0          48m
```

Here, you can see that `nginx-deployment` is deleted.
