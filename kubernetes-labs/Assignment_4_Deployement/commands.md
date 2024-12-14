# Deployment

1. check the running pods

```bash
$ kubectl get all
```
```fish
fish # kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   5d7h
```

2. run the `apply` command

```bash
$ kubectl apply -f 1_nginx-deployment-withRolling.yaml
```
```fish
fish # kubectl apply -f 1_nginx-deployment-withRolling.yaml
deployment.apps/testdeploy created
```

3. now, check the resources

```bash
$ kubectl get all
```
```fish
fish # kubectl get all
NAME                              READY   STATUS    RESTARTS   AGE
pod/testdeploy-674857b948-chcjd   1/1     Running   0          27s
pod/testdeploy-674857b948-dgzvw   1/1     Running   0          27s
pod/testdeploy-674857b948-tblrr   1/1     Running   0          27s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   5d7h

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/testdeploy   3/3     3            3           27s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/testdeploy-674857b948   3         3         3       27s
```

4. Lets, try to delete the pod

```bash
$ kubectl delete pod <pod_name>
```
```bash
example:
k delete pod testdeploy-65b7dbddd4-2wfnv
```
```fish
fish # kubectl delete pod testdeploy-674857b948-chcjd
pod "testdeploy-674857b948-chcjd" deleted
```

It will delete the pod. But, as the mentioned desired state 3 in replicaset, it will create a new pod. check it by using command:

```bash
$ kubectl get all
```

```fish
fish # kubectl get all
NAME                              READY   STATUS    RESTARTS   AGE
pod/testdeploy-674857b948-dgzvw   1/1     Running   0          2m5s
pod/testdeploy-674857b948-f9dj2   1/1     Running   0          37s
pod/testdeploy-674857b948-tblrr   1/1     Running   0          2m5s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   5d7h

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/testdeploy   3/3     3            3           2m5s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/testdeploy-674857b948   3         3         3       2m5s
```

**Replicaset restores the Pods.**

5. Now, lets try to delete the replicaset

```bash
$ kubectl delete rs <rs_name>
```
```fish
example:
k delete rs testdeploy-65b7dbddd4

fish # kubectl delete replicasets.apps testdeploy-674857b948
replicaset.apps "testdeploy-674857b948" deleted
```

**Deployment will restore the replciaset**
the replicaset will be automatically created. check it by using command:

```bash
$ kubectl get all
```
```fish
fish # kubectl get all
NAME                              READY   STATUS              RESTARTS   AGE
pod/testdeploy-674857b948-kjjc7   0/1     ContainerCreating   0          3s
pod/testdeploy-674857b948-lq2xv   0/1     ContainerCreating   0          3s
pod/testdeploy-674857b948-tldkt   0/1     ContainerCreating   0          3s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   5d7h

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/testdeploy   0/3     3            0           3m26s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/testdeploy-674857b948   3         3         0       3s
```

6. Now, lets change the nginx image version from `latest` to `stable`.
   first check the image version using command:

```bash
$ kubectl describe pods
```
```fish
fish # kubectl describe pods
Name:             testdeploy-674857b948-kjjc7
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Fri, 15 Nov 2024 15:48:15 +0530
Labels:           environment=test
                  pod-template-hash=674857b948
Annotations:      <none>
Status:           Running
IP:               10.244.0.39
IPs:
  IP:           10.244.0.39
Controlled By:  ReplicaSet/testdeploy-674857b948
Containers:
  nginx:
    Container ID:   docker://4980b36ae501bf49f0df7c3d38dc0eab7904121b59e54ce08389b7e76945ce4a
    Image:          nginx:latest
    Image ID:       docker-pullable://nginx@sha256:bc5eac5eafc581aeda3008b4b1f07ebba230de2f27d47767129a6a905c84f470
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 15 Nov 2024 15:48:20 +0530
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        500m
      memory:     256Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-9n7g2 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-9n7g2:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  80s   default-scheduler  Successfully assigned default/testdeploy-674857b948-kjjc7 to minikube
  Normal  Pulling    79s   kubelet            Pulling image "nginx:latest"
  Normal  Pulled     77s   kubelet            Successfully pulled image "nginx:latest" in 2.59s (2.59s including waiting). Image size: 191670156 bytes.
  Normal  Created    77s   kubelet            Created container nginx
  Normal  Started    76s   kubelet            Started container nginx


Name:             testdeploy-674857b948-lq2xv
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Fri, 15 Nov 2024 15:48:15 +0530
Labels:           environment=test
                  pod-template-hash=674857b948
Annotations:      <none>
Status:           Running
IP:               10.244.0.40
IPs:
  IP:           10.244.0.40
Controlled By:  ReplicaSet/testdeploy-674857b948
Containers:
  nginx:
    Container ID:   docker://409b40bad9596c93e0f3b85857c3618306b5659d21bc1c52f069a1b0fd6e0879
    Image:          nginx:latest
    Image ID:       docker-pullable://nginx@sha256:bc5eac5eafc581aeda3008b4b1f07ebba230de2f27d47767129a6a905c84f470
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 15 Nov 2024 15:48:22 +0530
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        500m
      memory:     256Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-pjvzj (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-pjvzj:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  80s   default-scheduler  Successfully assigned default/testdeploy-674857b948-lq2xv to minikube
  Normal  Pulling    79s   kubelet            Pulling image "nginx:latest"
  Normal  Pulled     74s   kubelet            Successfully pulled image "nginx:latest" in 2.726s (5.189s including waiting). Image size: 191670156 bytes.
  Normal  Created    74s   kubelet            Created container nginx
  Normal  Started    74s   kubelet            Started container nginx


Name:             testdeploy-674857b948-tldkt
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Fri, 15 Nov 2024 15:48:15 +0530
Labels:           environment=test
                  pod-template-hash=674857b948
Annotations:      <none>
Status:           Running
IP:               10.244.0.41
IPs:
  IP:           10.244.0.41
Controlled By:  ReplicaSet/testdeploy-674857b948
Containers:
  nginx:
    Container ID:   docker://64f3111163476ae71d9958d7a23df1b69a7ae738bc19ccc4519e3e65171072fd
    Image:          nginx:latest
    Image ID:       docker-pullable://nginx@sha256:bc5eac5eafc581aeda3008b4b1f07ebba230de2f27d47767129a6a905c84f470
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 15 Nov 2024 15:48:25 +0530
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        500m
      memory:     256Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-mxpq5 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-mxpq5:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  80s   default-scheduler  Successfully assigned default/testdeploy-674857b948-tldkt to minikube
  Normal  Pulling    79s   kubelet            Pulling image "nginx:latest"
  Normal  Pulled     71s   kubelet            Successfully pulled image "nginx:latest" in 2.671s (7.851s including waiting). Image size: 191670156 bytes.
  Normal  Created    71s   kubelet            Created container nginx
  Normal  Started    71s   kubelet            Started container nginx
```
you can also check replicaset
```bash
$ kubectl describe rs
```
```fish
fish # kubectl describe rs
Name:           testdeploy-674857b948
Namespace:      default
Selector:       environment=test,pod-template-hash=674857b948
Labels:         environment=test
                pod-template-hash=674857b948
Annotations:    deployment.kubernetes.io/desired-replicas: 3
                deployment.kubernetes.io/max-replicas: 4
                deployment.kubernetes.io/revision: 1
Controlled By:  Deployment/testdeploy
Replicas:       3 current / 3 desired
Pods Status:    3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  environment=test
           pod-template-hash=674857b948
  Containers:
   nginx:
    Image:      nginx:latest
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:         500m
      memory:      256Mi
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Events:
  Type    Reason            Age    From                   Message
  ----    ------            ----   ----                   -------
  Normal  SuccessfulCreate  2m13s  replicaset-controller  Created pod: testdeploy-674857b948-kjjc7
  Normal  SuccessfulCreate  2m13s  replicaset-controller  Created pod: testdeploy-674857b948-lq2xv
  Normal  SuccessfulCreate  2m13s  replicaset-controller  Created pod: testdeploy-674857b948-tldkt

you can also check deployment
```
```bash
$ kubectl describe deployment
```
```fish
fish # kubectl describe deployments
Name:                   testdeploy
Namespace:              default
CreationTimestamp:      Fri, 15 Nov 2024 15:44:52 +0530
Labels:                 environment=test
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               environment=test
Replicas:               3 desired | 3 updated | 3 total | 3 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        10
RollingUpdateStrategy:  0 max unavailable, 1 max surge
Pod Template:
  Labels:  environment=test
  Containers:
   nginx:
    Image:      nginx:latest
    Port:       <none>
    Host Port:  <none>
    Limits:
      cpu:         500m
      memory:      256Mi
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
NewReplicaSet:   testdeploy-674857b948 (3/3 replicas created)
Events:
  Type    Reason             Age                   From                   Message
  ----    ------             ----                  ----                   -------
  Normal  ScalingReplicaSet  2m46s (x2 over 6m9s)  deployment-controller  Scaled up replica set testdeploy-674857b948 to 3
```

7. change the `image version` in `deployment.yaml` file and now apply.

```bash
$ kubectl apply -f 1_nginx-deployment-withRolling.yaml
```
```fish
fish # kubectl apply -f 1_nginx-deployment-withRolling.yaml
deployment.apps/testdeploy configured
```

8. check the replicaset immediately

```bash
$ kubectl get all
```
```fish
fish # kubectl get all
NAME                              READY   STATUS        RESTARTS   AGE
pod/testdeploy-5f6d57d44d-6fwqt   0/1     Pending       0          0s
pod/testdeploy-5f6d57d44d-rcx9z   1/1     Running       0          15s
pod/testdeploy-674857b948-kjjc7   1/1     Running       0          5m11s
pod/testdeploy-674857b948-lq2xv   1/1     Running       0          5m11s
pod/testdeploy-674857b948-tldkt   1/1     Terminating   0          5m11s

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   5d8h

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/testdeploy   3/3     2            3           8m34s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/testdeploy-5f6d57d44d   2         2         1       15s
replicaset.apps/testdeploy-674857b948   2         2         2       5m11s
```

or use the command

```bash
$ k get rs --watch
```

```fish
fish # kubectl get rs --watch
NAME                    DESIRED   CURRENT   READY   AGE
testdeploy-5f6d57d44d   3         3         3       40s
testdeploy-674857b948   1         1         1       5m36s
testdeploy-5f6d57d44d   3         3         3       44s
testdeploy-674857b948   0         1         1       5m40s
testdeploy-674857b948   0         1         1       5m41s
testdeploy-674857b948   0         0         0       5m41s
```

9. now, chech the rs and you will find two replicaset, old and new.

```bash
$ kubectl get rs
```
```fish
fish # kubectl get rs
NAME                    DESIRED   CURRENT   READY   AGE
testdeploy-5f6d57d44d   3         3         3       87s
testdeploy-674857b948   0         0         0       6m23s
```

10. If you delete the old rs it will not get created automatically

```bash
$ kubectl get rs
```

```fish
fish # kubectl get rs
NAME                    DESIRED   CURRENT   READY   AGE
testdeploy-5f6d57d44d   3         3         3       2m47s
testdeploy-674857b948   0         0         0       7m43s
```
```bash
$ kubectl delete rs <rs_name>

example:
k delete rs testdeploy-65b7dbddd4
```
```fish
fish # kubectl delete replicasets.apps testdeploy-674857b948
replicaset.apps "testdeploy-674857b948" deleted
```
```bash
$ kubectl get rs
```
```fish
fish # kubectl get rs
NAME                    DESIRED   CURRENT   READY   AGE
testdeploy-5f6d57d44d   3         3         3       4m9s
```

11. check the version of nginx in new pods

```bash
$ kubectl get pods
```

```fish
fish # kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
testdeploy-5f6d57d44d-6fwqt   1/1     Running   0          4m12s
testdeploy-5f6d57d44d-rcx9z   1/1     Running   0          4m27s
testdeploy-5f6d57d44d-wshlr   1/1     Running   0          3m58s
```
```bash
$ kubectl describe pods
```
```fish
fish # kubectl describe pods
Name:             testdeploy-5f6d57d44d-6fwqt
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Fri, 15 Nov 2024 15:53:26 +0530
Labels:           environment=test
                  pod-template-hash=5f6d57d44d
Annotations:      <none>
Status:           Running
IP:               10.244.0.43
IPs:
  IP:           10.244.0.43
Controlled By:  ReplicaSet/testdeploy-5f6d57d44d
Containers:
  nginx:
    Container ID:   docker://b9387b264b13e1d3f59ca06da0a301087c66b9c83db000c1484d00f80cac781f
    Image:          nginx:stable
    Image ID:       docker-pullable://nginx@sha256:43d396487b4b924c47fa5823678e7e99f8241eda2394afd8f4fc8f3c286c2d5e
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 15 Nov 2024 15:53:30 +0530
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        500m
      memory:     256Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-pgfmg (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-pgfmg:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  4m27s  default-scheduler  Successfully assigned default/testdeploy-5f6d57d44d-6fwqt to minikube
  Normal  Pulling    4m27s  kubelet            Pulling image "nginx:stable"
  Normal  Pulled     4m24s  kubelet            Successfully pulled image "nginx:stable" in 2.617s (2.617s including waiting). Image size: 187702491 bytes.
  Normal  Created    4m24s  kubelet            Created container nginx
  Normal  Started    4m24s  kubelet            Started container nginx


Name:             testdeploy-5f6d57d44d-rcx9z
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Fri, 15 Nov 2024 15:53:11 +0530
Labels:           environment=test
                  pod-template-hash=5f6d57d44d
Annotations:      <none>
Status:           Running
IP:               10.244.0.42
IPs:
  IP:           10.244.0.42
Controlled By:  ReplicaSet/testdeploy-5f6d57d44d
Containers:
  nginx:
    Container ID:   docker://eaa7faa96426316911cc0c438d925897d073a262ad76ed0f2bb69d7c395e0f4b
    Image:          nginx:stable
    Image ID:       docker-pullable://nginx@sha256:43d396487b4b924c47fa5823678e7e99f8241eda2394afd8f4fc8f3c286c2d5e
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 15 Nov 2024 15:53:15 +0530
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        500m
      memory:     256Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-t44vt (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-t44vt:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  4m43s  default-scheduler  Successfully assigned default/testdeploy-5f6d57d44d-rcx9z to minikube
  Normal  Pulling    4m42s  kubelet            Pulling image "nginx:stable"
  Normal  Pulled     4m39s  kubelet            Successfully pulled image "nginx:stable" in 2.699s (2.699s including waiting). Image size: 187702491 bytes.
  Normal  Created    4m39s  kubelet            Created container nginx
  Normal  Started    4m39s  kubelet            Started container nginx


Name:             testdeploy-5f6d57d44d-wshlr
Namespace:        default
Priority:         0
Service Account:  default
Node:             minikube/192.168.49.2
Start Time:       Fri, 15 Nov 2024 15:53:40 +0530
Labels:           environment=test
                  pod-template-hash=5f6d57d44d
Annotations:      <none>
Status:           Running
IP:               10.244.0.44
IPs:
  IP:           10.244.0.44
Controlled By:  ReplicaSet/testdeploy-5f6d57d44d
Containers:
  nginx:
    Container ID:   docker://f52d0ab8e35c1323c4abcd4d07c446105b7f649cd953d41b9a897d66134a07d8
    Image:          nginx:stable
    Image ID:       docker-pullable://nginx@sha256:43d396487b4b924c47fa5823678e7e99f8241eda2394afd8f4fc8f3c286c2d5e
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Fri, 15 Nov 2024 15:53:44 +0530
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  256Mi
    Requests:
      cpu:        500m
      memory:     256Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-fd4l8 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True
  Initialized                 True
  Ready                       True
  ContainersReady             True
  PodScheduled                True
Volumes:
  kube-api-access-fd4l8:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  4m13s  default-scheduler  Successfully assigned default/testdeploy-5f6d57d44d-wshlr to minikube
  Normal  Pulling    4m13s  kubelet            Pulling image "nginx:stable"
  Normal  Pulled     4m10s  kubelet            Successfully pulled image "nginx:stable" in 2.724s (2.724s including waiting). Image size: 187702491 bytes.
  Normal  Created    4m10s  kubelet            Created container nginx
  Normal  Started    4m10s  kubelet            Started container nginx
```

12. delete the deployment

```bash
$ kubectl delete deployment <name>
```
```fish
fish # kubectl delete deployments.apps testdeploy
deployment.apps "testdeploy" deleted
fish # kubectl get all
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   5d8h
```
