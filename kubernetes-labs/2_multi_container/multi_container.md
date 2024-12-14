> [Go To home](../kubernetes-labs.md)

# Topics:

# 1. Create a mulitcontainers

create a file called `multi_container.yml`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: multi-container-pod
    labels:
        app: multi-container
spec:
    containers:
        - name: nginx-container
          image: nginx:latest
          ports:
              - containerPort: 80 # Nginx will listen on port 80
          env:
              - name: firstname
                value: Mihir
              - name: lastname
                value: Phadnis

        - name: busybox-container
          image: busybox:latest
          command: ["sh", "-c", "echo 'Hello from busybox!' && sleep 3600"] # Run a simple command and keep the container alive
          env:
              - name: City
                value: Pune
```

1. Create a Pod based on that manifest:

```bash
fish # kubectl apply -f multi_container.yml
pod/multi-container-pod created
```

2. List the running Pods:

```bash
fish # kubectl get pods
NAME                  READY   STATUS    RESTARTS   AGE
multi-container-pod   2/2     Running   0          55s
```

3. Check the logs from both containers

```bash
fish # kubectl logs multi-container-pod -c nginx-container
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2024/11/16 16:58:26 [notice] 1#1: using the "epoll" event method
2024/11/16 16:58:26 [notice] 1#1: nginx/1.27.2
2024/11/16 16:58:26 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2024/11/16 16:58:26 [notice] 1#1: OS: Linux 6.10.11-linuxkit
2024/11/16 16:58:26 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2024/11/16 16:58:26 [notice] 1#1: start worker processes
2024/11/16 16:58:26 [notice] 1#1: start worker process 29
2024/11/16 16:58:26 [notice] 1#1: start worker process 30
2024/11/16 16:58:26 [notice] 1#1: start worker process 31
2024/11/16 16:58:26 [notice] 1#1: start worker process 32
2024/11/16 16:58:26 [notice] 1#1: start worker process 33
2024/11/16 16:58:26 [notice] 1#1: start worker process 34
2024/11/16 16:58:26 [notice] 1#1: start worker process 35
2024/11/16 16:58:26 [notice] 1#1: start worker process 36
2024/11/16 16:58:26 [notice] 1#1: start worker process 37
2024/11/16 16:58:26 [notice] 1#1: start worker process 38
2024/11/16 16:58:26 [notice] 1#1: start worker process 39
2024/11/16 16:58:26 [notice] 1#1: start worker process 40

fish # kubectl logs multi-container-pod -c busybox-container
Hello from busybox!
```

4. check the names from multi_container.yml

```bash
fish # grep name multi_container.yml
    name: multi-container-pod
        - name: nginx-container
              - name: firstname
              - name: lastname
        - name: busybox-container
              - name: City
```

5. access shell of both containers

```bash
fish # kubectl exec --stdin --tty multi-container-pod -c nginx-container -- /bin/bash
root@multi-container-pod:/# cat /etc/os-release
PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
NAME="Debian GNU/Linux"
VERSION_ID="12"
VERSION="12 (bookworm)"
VERSION_CODENAME=bookworm
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
root@multi-container-pod:/#

fish # kubectl exec --stdin --tty multi-container-pod -c busybox-container -- /bin/sh
/ #
/home # echo "hello from busybox"
hello from busybox
```

# 2. INIT Containers

### What are Init Containers in Kubernetes?

-   Init Containers are special containers that run before the main application containers start in a pod. They are primarily used for setup tasks that need to be completed before the main containers can start.
-   Unlike regular application containers, init containers always run to completion and each one must finish successfully before the next one starts.
-   If an init container fails, Kubernetes will restart it until it succeeds. Only when all init containers have completed successfully will the pod's regular containers start.

#### When to Use Init Containers

-   You need to perform initialization tasks such as:
    -   Preloading data from an external source (e.g., fetching files from a remote location).
    -   Waiting for a service to be up and running (e.g., ensuring a database is available).
    -   Setting permissions or preparing files and directories.

#### Key Features of Init Containers:

-   Run before the main containers.
-   Run sequentially—one after another.
-   Each init container must complete successfully for the pod to proceed to the next container.
-   If they fail, Kubernetes will restart the pod and retry the init container.

#### Hands-On Example: Using Init Containers

Let's walk through an example where we use init containers to perform a simple task before starting the main container. In this case:

-   We have an init container that creates a directory.
-   The main container (an Nginx web server) will only start after the init container completes.

-   Step 1: Prepare the YAML File

Here’s a Kubernetes YAML file that demonstrates the use of init containers. create a file called: `init-container-demo.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: init-container-demo
    labels:
        app: init-container-demo
spec:
    initContainers:
        - name: init-myservice
          image: busybox:latest
          command: ["sh", "-c", 'echo "Initializing..." && echo "Hello from Init Container" > /app/index.html']
          volumeMounts:
              - name: shared-data
                mountPath: /app

    containers:
        - name: nginx
          image: nginx:latest
          ports:
              - containerPort: 80
          volumeMounts:
              - name: shared-data
                mountPath: /usr/share/nginx/html

    volumes:
        - name: shared-data
          emptyDir: {}
```

**Explanation:**

1. **Init Container (`init-myservice`):**

    - The busybox init container runs a shell command to:
        - Create a directory /app.
        - Write the text Hello from Init Container to a file named index.html in that directory.
    - This setup simulates preparing data before starting the main container.
    - The volume /app is mounted to store this data, which will be shared with the main container.

2. **Main Container (`nginx`):**

    - The nginx container starts after the init container completes.
    - It serves files from /usr/share/nginx/html, which is where the shared volume from the init container is mounted.
    - This means the index.html file created by the init container will be served by nginx.

3. **Volume (`shared-data`):**
    - An `emptyDir` volume is used to share data between the init container and the main container.
    - The `emptyDir` volume is empty at first, but the init container writes data to it, which is then used by the main container.

---

### Step 2: Deploy the Pod

1. Save the above YAML to a file named `init-container-demo.yaml`.

2. Apply the YAML using kubectl:

```bash
fish # kubectl apply -f init-container-demo.yaml
pod/init-container-demo created
```

3. Verify that the pod is created:

```bash
fish # kubectl get pods -o wide
NAME                  READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
init-container-demo   1/1     Running   0          43s   10.244.0.152   minikube   <none>           <none>
multi-container-pod   2/2     Running   0          22m   10.244.0.151   minikube   <none>           <none>
```

### Step 3: Inspect the Init Containers

You can check the status of the init containers:

```bash
kubectl describe pods init-container-demo
```

Look for the section Init Containers, which shows the status of each init container. You should see that the init container has successfully completed before the main nginx container starts.

### Step 4: Access the Nginx Web Server

Once the pod is running, you can verify that the file created by the init container is being served by the nginx container.

1. Forward the pod's port to your local machine to access the web server:

```bash
fish # kubectl describe pods init-container-demo > init-container.txt
fish # kubectl port-forward pods/init-container-demo 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
Handling connection for 8080
```

2. Open a web browser and go to http://localhost:8080. You should see the message:

```bash
fish # curl localhost:8080
Hello from Init Container
```

This message was created by the init container and is being served by the main nginx container.

### Step 5: Clean Up

When you're done with the example, you can delete the pod:

```bash
fish # kubectl delete pod init-container-demo
pod "init-container-demo" deleted
```
