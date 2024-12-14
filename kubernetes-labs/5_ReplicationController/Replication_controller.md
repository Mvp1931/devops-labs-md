> [Go To home](../kubernetes-labs.md)

# Replication Controller

#### A ReplicationController ensures that a specified number of pod replicas are running at any one time. In other words, a ReplicationController makes sure that a pod or a homogeneous set of pods is always up and available.

examples:

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
    name: rc
    labels:
        app: nginx
spec:
    replicas: 4
    selector:
        app: nginx
    template:
        metadata:
            name: nginx
            labels:
                app: nginx
        spec:
            containers:
                - name: container1
                  image: nginx:latest
```

```bash
fish # kubectl apply -f rc_demo.yml
replicationcontroller/rc created

fish # kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
rc-blfgf   1/1     Running   0          43s
rc-dk89x   1/1     Running   0          43s
rc-nxt98   1/1     Running   0          43s
rc-xwp42   1/1     Running   0          43s

fish # kubectl get replicationcontrollers
NAME   DESIRED   CURRENT   READY   AGE
rc     4         4         4       70s

fish # kubectl get pods --show-labels
NAME       READY   STATUS    RESTARTS   AGE    LABELS
rc-blfgf   1/1     Running   0          105s   app=nginx
rc-dk89x   1/1     Running   0          105s   app=nginx
rc-nxt98   1/1     Running   0          105s   app=nginx
rc-xwp42   1/1     Running   0          105s   app=nginx
```

Now, lets create a `Service` which will redirect the traffic to the RC

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
          nodePort: 30007
```

Now, this service will start manging the pods with labels app:nginx

```bash
fish # kubectl apply -f first_service.yml
service/my-service created

fish # kubectl get services
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        5d12h
my-service   NodePort    10.96.51.110   <none>        80:30007/TCP   19s

fish # minikube ip
192.168.49.2
```

check the service on browser: 192.168.49.2:30007 <minikubeip:nodePort>
Now, check: lets check what happen when you delete the pods

```bash
fish # kubectl get pods --show-labels -w
NAME       READY   STATUS    RESTARTS        AGE   LABELS
rc-blfgf   1/1     Running   1 (9m22s ago)   18m   app=nginx
rc-dk89x   1/1     Running   1 (9m22s ago)   18m   app=nginx
rc-nxt98   1/1     Running   1 (9m22s ago)   18m   app=nginx
rc-xwp42   1/1     Running   1 (9m22s ago)   18m   app=nginx

#duplicate the terminal window
fish # kubectl delete pod rc-xwp42
pod "rc-xwp42" deleted

rc-xwp42   1/1     Terminating         1 (10m ago)     19m   app=nginx
rc-h5mgs   0/1     Pending             0               0s    app=nginx
rc-h5mgs   0/1     ContainerCreating   0               0s    app=nginx
rc-xwp42   0/1     Completed           1 (10m ago)     19m   app=nginx
rc-h5mgs   1/1     Running             0               4s    app=nginx
```

You can watch replication controller state also.

```bash
fish # kubectl get rc -w
NAME   DESIRED   CURRENT   READY   AGE
rc     4         4         4       22m
#duplicate the terminal window
fish # kubectl get pods
NAME       READY   STATUS    RESTARTS      AGE
rc-blfgf   1/1     Running   1 (13m ago)   22m
rc-dk89x   1/1     Running   1 (13m ago)   22m
rc-h5mgs   1/1     Running   0             3m11s
rc-nxt98   1/1     Running   1 (13m ago)   22m
fish # kubectl delete pod rc-dk89x rc-blfgf
pod "rc-dk89x" deleted
pod "rc-blfgf" deleted

fish # kubectl describe rc
Name:         rc
Namespace:    default
Selector:     app=nginx
Labels:       app=nginx
Annotations:  <none>
Replicas:     4 current / 4 desired
Pods Status:  4 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=nginx
  Containers:
   container1:
    Image:         nginx:latest
    Port:          <none>
    Host Port:     <none>
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Events:
  Type    Reason            Age    From                    Message
  ----    ------            ----   ----                    -------
  Normal  SuccessfulCreate  24m    replication-controller  Created pod: rc-nxt98
  Normal  SuccessfulCreate  24m    replication-controller  Created pod: rc-dk89x
  Normal  SuccessfulCreate  24m    replication-controller  Created pod: rc-blfgf
  Normal  SuccessfulCreate  24m    replication-controller  Created pod: rc-xwp42
  Normal  SuccessfulCreate  4m59s  replication-controller  Created pod: rc-h5mgs
  Normal  SuccessfulCreate  67s    replication-controller  Created pod: rc-tmt2k
  Normal  SuccessfulCreate  67s    replication-controller  Created pod: rc-x875s
```

Now, lets remove the label of first pod i.e.

```bash
NAME       READY   STATUS    RESTARTS      AGE     LABELS
rc-h5mgs   1/1     Running   0             5m37s   app=nginx
rc-nxt98   1/1     Running   1 (15m ago)   24m     app=nginx
rc-tmt2k   1/1     Running   0             105s    app=nginx
rc-x875s   1/1     Running   0             105s    app=nginx

fish # kubectl label pod rc-nxt98 app-
pod/rc-nxt98 unlabeled

$ kubectl get pods --show-labels

fish # kubectl get pods --show-labels
NAME       READY   STATUS    RESTARTS      AGE   LABELS
rc-h5mgs   1/1     Running   0             10h   app=nginx
rc-nxt98   1/1     Running   1 (10h ago)   10h   <none>
rc-qbqsw   1/1     Running   0             5s    app=nginx
rc-tmt2k   1/1     Running   0             10h   app=nginx
rc-x875s   1/1     Running   0             10h   app=nginx
```

Now, check the service also. service also match the labels. if you remove the label, service also doesnt consider the pod which label doesnt match

```bash
fish # kubectl describe service my-service
Name:                     my-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=nginx
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.96.51.110
IPs:                      10.96.51.110
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  30007/TCP
Endpoints:                10.244.0.61:80,10.244.0.62:80,10.244.0.63:80 + 1 more...
Session Affinity:         None
External Traffic Policy:  Cluster
Internal Traffic Policy:  Cluster
Events:                   <none>

#check the endpoint IPs

fish # kubectl get pods -o wide
NAME       READY   STATUS    RESTARTS      AGE     IP            NODE       NOMINATED NODE   READINESS GATES
rc-h5mgs   1/1     Running   0             10h     10.244.0.61   minikube   <none>           <none>
rc-nxt98   1/1     Running   1 (10h ago)   10h     10.244.0.60   minikube   <none>           <none>
rc-qbqsw   1/1     Running   0             2m14s   10.244.0.64   minikube   <none>           <none>
rc-tmt2k   1/1     Running   0             10h     10.244.0.62   minikube   <none>           <none>
rc-x875s   1/1     Running   0             10h     10.244.0.63   minikube   <none>           <none>
```

## Delete the Repelication Controller

```bash
fish # kubectl delete replicationcontrollers rc
replicationcontroller "rc" deleted
```

## Now delete the RC but the pods managed by RC should not be deleted

```bash
kubectl delete rc --cascade=false rc
OR
kubectl delete rc rc --cascade=orphan

fish # kubectl get pods --show-labels -o wide
NAME       READY   STATUS    RESTARTS      AGE   IP            NODE       NOMINATED NODE   READINESS GATES   LABELS
rc-nxt98   1/1     Running   1 (10h ago)   10h   10.244.0.60   minikube   <none>           <none>            <none>

#delete all pods
fish # kubectl delete pods --all
pod "rc-nxt98" deleted
```

# ReplicationController Scaling

## First Way - Imperative Command

```bash
fish # kubectl apply -f rc_demo.yml
replicationcontroller/rc created
fish # kubectl get all
NAME           READY   STATUS              RESTARTS   AGE
pod/rc-8w45d   1/1     Running             0          11s
pod/rc-jhhcm   1/1     Running             0          11s
pod/rc-pswxb   1/1     Running             0          11s
pod/rc-xfxr6   0/1     ContainerCreating   0          11s

NAME                       DESIRED   CURRENT   READY   AGE
replicationcontroller/rc   4         4         3       11s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        5d23h
service/my-service   NodePort    10.96.51.110   <none>        80:30007/TCP   10h

# scale the rc

fish # kubectl scale rc --replicas 2 rc
replicationcontroller/rc scaled
fish # kubectl get all
NAME           READY   STATUS    RESTARTS   AGE
pod/rc-8w45d   1/1     Running   0          78s
pod/rc-pswxb   1/1     Running   0          78s

NAME                       DESIRED   CURRENT   READY   AGE
replicationcontroller/rc   2         2         2       78s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        5d23h
service/my-service   NodePort    10.96.51.110   <none>        80:30007/TCP   10h
```

## Second Way - Imperative Object configuration

```bash
fish # kubectl edit rc rc
replicationcontroller/rc edited
fish # kubectl get all
NAME           READY   STATUS    RESTARTS   AGE
pod/rc-8w45d   1/1     Running   0          2m57s
pod/rc-m64zz   1/1     Running   0          7s
pod/rc-pswxb   1/1     Running   0          2m57s # as you can see I edited rc replicas from 2 to 3

NAME                       DESIRED   CURRENT   READY   AGE
replicationcontroller/rc   3         3         3       2m57s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        5d23h
service/my-service   NodePort    10.96.51.110   <none>        80:30007/TCP   10h
```

## Third Way - Declarative Configuration

```bash
fish # vim ./rc_demo.yml
fish # kubectl apply -f rc_demo.yml
replicationcontroller/rc configured
fish # kubectl get all
NAME           READY   STATUS    RESTARTS   AGE
pod/rc-8w45d   1/1     Running   0          5m46s
pod/rc-bjxvz   1/1     Running   0          83s
pod/rc-l5p6l   1/1     Running   0          83s
pod/rc-m64zz   1/1     Running   0          2m56s
pod/rc-pswxb   1/1     Running   0          5m46s # and here I changed replicas from 3 to 5.

NAME                       DESIRED   CURRENT   READY   AGE
replicationcontroller/rc   5         5         3       5m46s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        5d23h
service/my-service   NodePort    10.96.51.110   <none>        80:30007/TCP   10h
```

# How ReplicationController Works

1. Delete all the resources first

```bash
fish # kubectl delete rc rc
replicationcontroller "rc" deleted
fish # kubectl get all
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        5d23h
service/my-service   NodePort    10.96.51.110   <none>        80:30007/TCP   11h
```

2. Create a `firstpod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: firstpod
    labels:
        app: nginx
spec:
    containers:
        - name: firstcontainer
          image: nginx:latest
          ports:
              - containerPort: 80
                name: http
```

check the pod status

```bash
kubectl get pods --show-labels -o wide
#check the label
fish # kubectl describe pods firstpod > before_rc.txt
```

3. Create a `firstrc.yml`

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
    name: firstrc
    labels:
        app: nginx
spec:
    replicas: 1
    template:
        metadata:
            name: firstpod
            labels:
                app: nginx
        spec:
            containers:
                - name: firstcontainer
                  image: nginx:latest
```

Now, check whether a new pod is created or not. No new pod is created as one pod was already running with label `app: nginx`.

```bash
replicationcontroller/firstrc created
fish # kubectl get pods --show-labels -o wide
NAME       READY   STATUS    RESTARTS   AGE     IP            NODE       NOMINATED NODE   READINESS GATES   LABELS
firstpod   1/1     Running   0          2m47s   10.244.0.72   minikube   <none>           <none>            app=nginx
```

now, describe the pod and check the field `ControlledBy`. compare the output of current `describe` command with `before_rc.txt` file output.

> **NOTE**
>
> RC first checks if the pod is available and nobody owns it, or the pod is not controlled by anyone. then it just start managing it.

4. Now, lets create a another file `secondrc.yml`

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
    name: secondrc
spec:
    replicas: 1
    selector:
        app: nginx
    template:
        metadata:
            name: secondpod
            labels:
                app: nginx
        spec:
            containers:
                - name: secondcontainer
                  image: nginx:latest
                  ports:
                      - containerPort: 80
```

Now, check whether a new pod is created or not. The new pod is created by the `secondrc` even though the labels are matched i.e. `app:nginx`.
because, even though the same label pod is running but that pod is owned by `firstrc`.

```bash
fish # kubectl apply -f secondrc.yaml
replicationcontroller/secondrc created
fish # kubectl get all
NAME                 READY   STATUS    RESTARTS   AGE
pod/firstpod         1/1     Running   0          8m21s
pod/secondrc-9xcg5   1/1     Running   0          21s

NAME                             DESIRED   CURRENT   READY   AGE
replicationcontroller/firstrc    1         1         1       5m40s
replicationcontroller/secondrc   1         1         1       21s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP        5d23h
service/my-service   NodePort    10.96.51.110   <none>        80:30007/TCP   11h
```

> **NOTE**
>
> RC first checks if the pod is available. If pod is available then it checks the owner, if it is already owned by someone else then it will create a new pod.

5. Clean the resources

```bash
fish # kubectl delete replicationcontrollers firstrc secondrc
replicationcontroller "firstrc" deleted
replicationcontroller "secondrc" deleted
```
