> [Go To home](../kubernetes-labs.md)

# ReplicaSet

A ReplicaSet's purpose is to maintain a stable set of replica Pods running at any given time. Usually, you define a Deployment and let that Deployment manage ReplicaSets automatically.

## How a ReplicaSet works

A ReplicaSet is defined with fields, including a selector that specifies how to identify Pods it can acquire, a number of replicas indicating how many Pods it should be maintaining, and a pod template specifying the data of new Pods it should create to meet the number of replicas criteria. A ReplicaSet then fulfills its purpose by creating and deleting Pods as needed to reach the desired number. When a ReplicaSet needs to create new Pods, it uses its Pod template.

## When to use a ReplicaSet

A ReplicaSet ensures that a specified number of pod replicas are running at any given time. However, a Deployment is a higher-level concept that manages ReplicaSets and provides declarative updates to Pods along with a lot of other useful features. Therefore, we recommend using Deployments instead of directly using ReplicaSets, unless you require custom update orchestration or don't require updates at all.

This actually means that you may never need to manipulate ReplicaSet objects: use a Deployment instead, and define your application in the spec section.

## Difference between ReplicaController and ReplicaSet

| **Feature**                 | **ReplicationController (RC)**                                            | **ReplicaSet (RS)**                                              |
| --------------------------- | ------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| **Definition**              | Ensures a specified number of pod replicas are running at any given time. | Newer form of ReplicationController, supports advanced features. |
| **Selector Type**           | Supports equality-based selectors only.                                   | Supports both equality-based and set-based selectors.            |
| **Supported Selectors**     | Only supports selectors like `env=prod`.                                  | Supports selectors like `env in (prod, dev)`.                    |
| **Usage**                   | Older resource, being phased out in favor of ReplicaSet.                  | More powerful and flexible; recommended for new workloads.       |
| **Rolling Updates**         | Does not natively support rolling updates.                                | Can be used with Deployments for rolling updates.                |
| **Adoption by Deployments** | Not typically used with Deployments.                                      | Primarily managed by Deployments for scalable workloads.         |
| **Recommendation**          | Deprecated and not recommended for new projects.                          | Preferred and modern way to maintain pod replicas.               |
| **Deprecation Status**      | Slowly being deprecated in favor of ReplicaSet and Deployments.           | Actively supported and part of modern Kubernetes workflows.      |

# Demo

## ReplicationController Demo

1. Create a two files `firstpod.yml` and `secondpod.yml`
   `firstpod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: pod1
    labels:
        app: myapp1
        type: frontend
spec:
    containers:
        - name: myapp1-container
          image: nginx:latest
          ports:
              - containerPort: 80
                name: http
```

`secondpod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: pod2
    labels:
        app: myapp
        type: frontend
spec:
    containers:
        - name: myapp-container
          image: nginx:latest
          ports:
              - containerPort: 80
                name: http
```

create pods

```bash
fish # kubectl apply -f firstpod.yml
pod/pod1 created
fish # kubectl apply -f secondpod.yml
pod/pod2 created

fish # kubectl get pods -o wide --show-labels
NAME   READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES   LABELS
pod1   1/1     Running   0          56s   10.244.0.78   minikube   <none>           <none>            app=myapp1,type=frontend
pod2   1/1     Running   0          42s   10.244.0.79   minikube   <none>           <none>            app=myapp,type=frontend
```

2. Create a `firstrc.yml`

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
    name: firstrc
    labels:
        name: firstrc
spec:
    replicas: 2
    selector:
        app: myapp
    template:
        metadata:
            name: firstpod
            labels:
                app: myapp
        spec:
            containers:
                - name: firstcontainer
                  image: nginx:latest
                  ports:
                      - containerPort: 80
```

creae a repliccontroller

```bash
fish # kubectl create -f firstrc.yml
replicationcontroller/firstrc created
fish # kubectl get pods -o wide --show-labels
NAME            READY   STATUS    RESTARTS   AGE    IP            NODE       NOMINATED NODE   READINESS GATES   LABELS
firstrc-2mjr4   1/1     Running   0          16s    10.244.0.80   minikube   <none>           <none>            app=myapp
pod1            1/1     Running   0          107s   10.244.0.78   minikube   <none>           <none>            app=myapp1,type=frontend
pod2            1/1     Running   0          93s    10.244.0.79   minikube   <none>           <none>            app=myapp,type=frontend
```

> **NOTE**
>
> Here, rc will create only one new pod as one pod with `label app:myapp` is already running and nobody owns it.
> So, this is called `equality-based` comparison.
> In firstrc.yml we specified `selector, app:myapp`. so it will check the pods with label `app:myapp` and it should not be owned by anyone. then it will start managing it. This is equality-based.

---

### Now, the requirement is like "Create a new ReplicationController which will manage the pods which have labels `myapp OR myapp1` (anyone of these label)" This is called as `Set-base selector`.

1. first delete all the resources

```bash
fish # kubectl delete -f firstrc.yml
replicationcontroller "firstrc" deleted
fish # kubectl get all
NAME       READY   STATUS    RESTARTS   AGE
pod/pod1   1/1     Running   0          4m28s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        6d2h
service/my-service   NodePort    10.96.51.110   <none>        80:30007/TCP   13h

# note here we have deleted the rc which was created with label app:myapp, so it will delete new pod and one with label app:myapp

fish # kubectl delete pods pod1
pod "pod1" deleted # delete the pod which was created with label app:myapp1
```

## ReplicaSet Demo

> **Now, the same thing which we have achieved through ReplicationController we will try to do it with the ReplicaSet**

1. Create pods

```bash
fish # kubectl create -f firstpod.yml
pod/pod1 created
fish # kubectl create -f secondpod.yml
pod/pod2 created
fish # kubectl get pods -o wide --show-labels
NAME   READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES   LABELS
pod1   1/1     Running   0          33s   10.244.0.81   minikube   <none>           <none>            app=myapp1,type=frontend
pod2   1/1     Running   0          14s   10.244.0.82   minikube   <none>           <none>            app=myapp,type=frontend
```

2. Create a file `firstrs.yml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: firstrs
    labels:
        name: firstrs
spec:
    replicas: 2
    #  selector:
    #    app: myapp
    template:
        metadata:
            name: firstpod
            labels:
                app: myapp
        spec:
            containers:
                - name: firstcontainer
                  image: nginx:latest
                  ports:
                      - containerPort: 80
```

create a ReplicaSet

```bash
$ kubectl create -f firstrs.yml

# IT WILL THROW AN ERROR
The ReplicaSet "firstrs" is invalid:
* spec.selector: Required value
* spec.template.metadata.labels: Invalid value: map[string]string{"app":"myapp"}: `selector` does not match template `labels`
```

> **NOTE**
>
> In the case of a `ReplicationController`, if you don't specify the `selector`, it defaults to using the `labels of the pods as the selector`. However, for a `ReplicaSet`, you must explicitly specify the `selector`, otherwise, it will throw an error.

**Modify the file `firstrs.yml`, remove the comments. and add matchLabel field**

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: firstrs
    labels:
        name: firstrs
spec:
    replicas: 2
    selector:
        matchLabels:
            app: myapp
    template:
        metadata:
            name: firstpod
            labels:
                app: myapp
        spec:
            containers:
                - name: firstcontainer
                  image: nginx:latest
                  ports:
                      - containerPort: 80
```

create a ReplicaSet

```bash
fish # kubectl apply -f firstrs.yml --dry-run=client
replicaset.apps/firstrs created (dry run)
fish # kubectl create -f firstrs.yml
replicaset.apps/firstrs created

$ kubectl describe pod | less
```

## Delete the ReplicaSet

```bash
fish # kubectl delete rs firstrs
replicaset.apps "firstrs" deleted
fish # kubectl get rs
No resources found in default namespace.
```

## Lets check the functionalities that are provided by the RS and not availabel in RC

1. Create a `thirdpod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: pod3
    labels:
        app: myapp3
        type: frontend
spec:
    containers:
        - name: myapp1-container
          image: nginx:latest
          ports:
              - containerPort: 80
                name: http
```

2. Create a `fourthpod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: pod4
    labels:
        app: myapp4
        type: backend
spec:
    containers:
        - name: myapp1-container
          image: nginx:latest
          ports:
              - containerPort: 80
                name: http
```

Create a pod3 and pod4

```bash
fish # kubectl create -f thirdpod.yml
pod/pod3 created
fish # kubectl create -f fourthpod.yml
pod/pod4 created
fish # kubectl get pods -o wide --show-labels
NAME   READY   STATUS    RESTARTS   AGE    IP            NODE       NOMINATED NODE   READINESS GATES   LABELS
pod1   1/1     Running   0          6m4s   10.244.0.84   minikube   <none>           <none>            app=myapp1,type=frontend
pod3   1/1     Running   0          16s    10.244.0.87   minikube   <none>           <none>            app=myapp3,type=frontend
pod4   1/1     Running   0          13s    10.244.0.88   minikube   <none>           <none>            app=myapp4,type=backend
```

check the help

```bash
kubectl explain rs --recursive | less
```

> In Spec -> selector -> matchLabels represents the `equility-based` comparision. Now, we want `set-based comparions`.
> So, select Spec-> selector -> matchExpressions.

Now, create the file `secondrs.yml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: secondrs
    labels:
        name: secondrs
spec:
    replicas: 3
    selector:
        matchExpressions:
            - key: app
              operator: In
              values:
                  - myapp3
                  - myapp4
    template:
        metadata:
            name: firstpod
            labels:
                app: myapp3
        spec:
            containers:
                - name: firstcontainer
                  image: nginx:latest
                  ports:
                      - containerPort: 80
```

Create a replicacontroller

```bash
fish # kubectl apply -f secondrs.yml
replicaset.apps/secondrs created
fish # kubectl get pods -o wide --show-labels
NAME             READY   STATUS    RESTARTS   AGE     IP            NODE       NOMINATED NODE   READINESS GATES   LABELS
pod1             1/1     Running   0          13m     10.244.0.84   minikube   <none>           <none>            app=myapp1,type=frontend
pod3             1/1     Running   0          7m14s   10.244.0.87   minikube   <none>           <none>            app=myapp3,type=frontend
pod4             1/1     Running   0          7m11s   10.244.0.88   minikube   <none>           <none>            app=myapp4,type=backend
secondrs-qkhtz   1/1     Running   0          21s     10.244.0.89   minikube   <none>           <none>            app=myapp3
#Check the SELECTOR filed in the output
```

> **NOTE**
>
> It will create a only one new pod as the two pods are already running with the lables myapp3 and myapp4.

### Delete the replicaset

```bash
fish # kubectl delete rs secondrs
replicaset.apps "secondrs" deleted
fish # kubectl get pods
NAME   READY   STATUS    RESTARTS   AGE
pod1   1/1     Running   0          14m
# This will delete all the pods owned by secondrs
```

Lets, create three new pods :

1. `fifthpod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: pod5
    labels:
        app: myapp
        type: frontend
spec:
    containers:
        - name: myapp1-container
          image: nginx:latest
          ports:
              - containerPort: 80
                name: http
```

2. `sixthpod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: pod6
    labels:
        app: myapp
        type: backend
spec:
    containers:
        - name: myapp1-container
          image: nginx:latest
          ports:
              - containerPort: 80
                name: http
```

3. `sevenpod.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: pod7
    labels:
        app: myapp1
        type: frontend
spec:
    containers:
        - name: myapp1-container
          image: nginx:latest
          ports:
              - containerPort: 80
                name: http
```

```bash
fish # kubectl apply -f fifthpod.yml
pod/pod5 created
fish # kubectl apply -f sixthpod.yml
pod/pod6 created
fish # kubectl apply -f sevenpod.yml
pod/pod7 created
fish # kubectl get all
NAME       READY   STATUS    RESTARTS   AGE
pod/pod1   1/1     Running   0          16m
pod/pod5   1/1     Running   0          20s
pod/pod6   1/1     Running   0          16s
pod/pod7   1/1     Running   0          8s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        6d2h
service/my-service   NodePort    10.96.51.110   <none>        80:30007/TCP   14h
```

#### Now the requirement is that.. Create a RS in which `app=myapp` and `myapp1` must be there but it should not contain the pod which have label type=backend

Create a new file `thirdrs.yml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: thirdrs
    labels:
        app: thirdrs
spec:
    # modify replicas according to your case
    replicas: 3
    selector:
        matchExpressions:
            - key: app
              operator: In
              values:
                  - myapp
                  - myapp1
            - key: type
              operator: NotIn
              values:
                  - backend
    template:
        metadata:
            labels:
                app: myapp1
        spec:
            containers:
                - name: firstcontainer
                  image: nginx:latest
                  ports:
                      - containerPort: 80
```

-   Crate the replica-set

```bash
fish # kubectl apply -f thirdrs.yml
replicaset.apps/thirdrs created
fish # kubectl get all
NAME                READY   STATUS    RESTARTS   AGE
pod/pod1            1/1     Running   0          20m
pod/pod5            1/1     Running   0          4m51s
pod/pod6            1/1     Running   0          4m47s
pod/pod7            1/1     Running   0          4m39s
pod/thirdrs-qrp4s   1/1     Running   0          6s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        6d2h
service/my-service   NodePort    10.96.51.110   <none>        80:30007/TCP   14h

NAME                      DESIRED   CURRENT   READY   AGE
replicaset.apps/thirdrs   4         4         4       6s
```

> to check the output describe the pod which have `label=backend` and check `controlled by`

```bash
fish # kubectl describe pods -l type=backend
Name:             pod6
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Sat, 16 Nov 2024 10:38:29 +0530
Labels:           app=myapp
                  type=backend
Annotations:      <none>
Status:           Running
IP:               10.244.0.91
IPs:
  IP:  10.244.0.91
Containers:
  myapp1-container:
    Container ID:   docker://628ace0b49e15a6f516dbbc55d5411c03a6f2151df2b8db022c3bb0e101faf07
    Image:          nginx:latest
    Image ID:       docker-pullable://nginx@sha256:bc5eac5eafc581aeda3008b4b1f07ebba230de2f27d47767129a6a905c84f470
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 16 Nov 2024 10:38:33 +0530
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-m87j8 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-m87j8:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6m57s  default-scheduler  Successfully assigned default/pod6 to minikube
  Normal  Pulling    6m57s  kubelet            Pulling image "nginx:latest"
  Normal  Pulled     6m54s  kubelet            Successfully pulled image "nginx:latest" in 2.732s (2.732s including waiting). Image size: 191670156 bytes.
  Normal  Created    6m54s  kubelet            Created container myapp1-container
  Normal  Started    6m54s  kubelet            Started container myapp1-container
```

# Now delete the rs (cleanup)

```bash
fish # kubectl delete rs thirdrs
replicaset.apps "thirdrs" deleted
```

**Always use `Deployemnt` to create the PODS**
