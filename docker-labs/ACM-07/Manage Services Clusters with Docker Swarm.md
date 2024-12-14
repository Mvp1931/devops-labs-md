> [Go to Home](../docker-labs.md)

# Step 1 initialize Docker Swarm in the Host.

```powershell
pwsh # docker swarm init
Swarm initialized: current node (nonaeff3792tk4jrjpp8w1djz) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-550jun23jczvgccnz85licbes13f42v1spdukdxmtp4cbbytju-9256gwk2k0jjf7n6g6q6buxj9 192.168.65.3:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

## Step 1.1 Initialize workers with `docker-in-docker` image.

```powershell
pwsh # docker run -d --privileged --name worker1 --hostname=worker1 docker:dind
c6b71d24f0696957fedc4eb54089e2abf8c63a028405b0dc66a3b7a43009ced5
pwsh # docker run -d --privileged --name worker2 --hostname=worker2 docker:dind
79d2ac0e8191bcf1e00632454f89898eb38097f72685c0d259cebb9fa90bf4a4
```

## Step 1.2 Join Worker nodes to Swarm Manager node.

```powershell
pwsh # docker exec -it c6b7 docker swarm join --token SWMTKN-1-550jun23jczvgccnz85licbes13f42v1spdukdxmtp4cbbytju-9256gwk2k0jjf7n6g6q6buxj9 192.168.65.3:2377
This node joined a swarm as a worker.

"What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug c6b7
    Learn more at https://docs.docker.com/go/debug-cli/
"
pwsh # docker exec -it 79d2 docker swarm join --token SWMTKN-1-550jun23jczvgccnz85licbes13f42v1spdukdxmtp4cbbytju-9256gwk2k0jjf7n6g6q6buxj9 192.168.65.3:2377
This node joined a swarm as a worker.

"What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug 79d2"
```

## Step 1.3 Verify Node states.

```powershell
pwsh # docker node ls
ID                            HOSTNAME         STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
nonaeff3792tk4jrjpp8w1djz *   docker-desktop   Ready     Active         Leader           27.1.1
xauln9r3f525tsr3iv6cr293k     worker1          Ready     Active                          27.1.2
ohk68o6ltovozre6gu0m7fo2s     worker2          Ready     Active                          27.1.2
```

# Step 2 Create Docker Swarm Service.

```powershell
pwsh # docker service create --name nginx-swarm --replicas 3 -p 8080:80 nginx:stable
qwbmsgxhq0g4juastpffiqqfh
overall progress: 3 out of 3 tasks
1/3: running   [==================================================>]
2/3: running   [==================================================>]
3/3: running   [==================================================>]
verify: Service qwbmsgxhq0g4juastpffiqqfh converged
```

## Step 2.1 Check running services.

```powershell
pwsh # docker service ls
ID             NAME          MODE         REPLICAS   IMAGE          PORTS
qwbmsgxhq0g4   nginx-swarm   replicated   3/3        nginx:stable   *:8080->80/tcp
pwsh # docker service ps nginx-swarm
ID             NAME            IMAGE          NODE             DESIRED STATE   CURRENT STATE               ERROR     PORTS
4bxjqlg5hijc   nginx-swarm.1   nginx:stable   worker2          Running         Running about an hour ago
w9g2un638qpf   nginx-swarm.2   nginx:stable   docker-desktop   Running         Running about an hour ago
tqsbctqs19c0   nginx-swarm.3   nginx:stable   worker1          Running         Running about an hour ago
```

to see if service is running, go to exposed port on your machine.
![running-swarm-output-web](./swarm-web.png)

## Step 2.2 Check if docker maintains desired state.

Remove 1 Server and check services.

```powershell
pwsh # docker node rm worker2 -f
worker2
pwsh # docker node ls
ID                            HOSTNAME         STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
nonaeff3792tk4jrjpp8w1djz *   docker-desktop   Ready     Active         Leader           27.1.1
xauln9r3f525tsr3iv6cr293k     worker1          Ready     Active                          27.1.2
pwsh # docker node rm worker1 -f
worker1
pwsh # docker node ls
ID                            HOSTNAME         STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
nonaeff3792tk4jrjpp8w1djz *   docker-desktop   Ready     Active         Leader           27.1.1
pwsh # docker service ps nginx-swarm
ID             NAME                IMAGE          NODE                        DESIRED STATE   CURRENT STATE               ERROR     PORTS
a2ep5adspbar   nginx-swarm.1       nginx:stable   docker-desktop              Running         Running 47 seconds ago
4bxjqlg5hijc    \_ nginx-swarm.1   nginx:stable   ohk68o6ltovozre6gu0m7fo2s   Shutdown        Orphaned 53 seconds ago
w9g2un638qpf   nginx-swarm.2       nginx:stable   docker-desktop              Running         Running about an hour ago
ns840rb5x55x   nginx-swarm.3       nginx:stable   docker-desktop              Running         Running 10 seconds ago
tqsbctqs19c0    \_ nginx-swarm.3   nginx:stable   xauln9r3f525tsr3iv6cr293k   Shutdown        Orphaned 15 seconds ago
```

(it does not maintain desired state... why??)

## Step 2.3 Check if services are scaled up

```powershell
pwsh # docker service scale nginx-swarm=5
nginx-swarm scaled to 5
overall progress: 5 out of 5 tasks
1/5: running   [==================================================>]
2/5: running   [==================================================>]
3/5: running   [==================================================>]
4/5: running   [==================================================>]
5/5: running   [==================================================>]
verify: Service nginx-swarm converged
pwsh # docker node ls
ID                            HOSTNAME         STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
nonaeff3792tk4jrjpp8w1djz *   docker-desktop   Ready     Active         Leader           27.1.1
pwsh # docker service ps nginx-swarm
ID             NAME                IMAGE          NODE                        DESIRED STATE   CURRENT STATE               ERROR     PORTS
a2ep5adspbar   nginx-swarm.1       nginx:stable   docker-desktop              Running         Running 3 minutes ago
4bxjqlg5hijc    \_ nginx-swarm.1   nginx:stable   ohk68o6ltovozre6gu0m7fo2s   Shutdown        Orphaned 3 minutes ago
w9g2un638qpf   nginx-swarm.2       nginx:stable   docker-desktop              Running         Running about an hour ago
ns840rb5x55x   nginx-swarm.3       nginx:stable   docker-desktop              Running         Running 2 minutes ago
tqsbctqs19c0    \_ nginx-swarm.3   nginx:stable   xauln9r3f525tsr3iv6cr293k   Shutdown        Orphaned 2 minutes ago
2l1nkftm2rby   nginx-swarm.4       nginx:stable   docker-desktop              Running         Running 18 seconds ago
a0yufvdz1xyi   nginx-swarm.5       nginx:stable   docker-desktop              Running         Running 18 seconds ago
```

## Step 2.4 Scale Down Services

```powershell
pwsh # docker service scale nginx-swarm=2
nginx-swarm scaled to 2
overall progress: 2 out of 2 tasks
1/2: running   [==================================================>]
2/2: running   [==================================================>]
verify: Service nginx-swarm converged
pwsh # docker service ps nginx-swarm
ID             NAME                IMAGE          NODE                        DESIRED STATE   CURRENT STATE             ERROR     PORTS
a2ep5adspbar   nginx-swarm.1       nginx:stable   docker-desktop              Running         Running 23 minutes ago
4bxjqlg5hijc    \_ nginx-swarm.1   nginx:stable   ohk68o6ltovozre6gu0m7fo2s   Shutdown        Orphaned 24 minutes ago
w9g2un638qpf   nginx-swarm.2       nginx:stable   docker-desktop              Running         Running 2 hours ago
tqsbctqs19c0   nginx-swarm.3       nginx:stable   xauln9r3f525tsr3iv6cr293k   Shutdown        Orphaned 23 minutes ago
```

# Step 3 Update the services.

> Update nginx image to latest

```powershell
pwsh # docker service update --image nginx:latest nginx-swarm
nginx-swarm
overall progress: 2 out of 2 tasks
1/2: running   [==================================================>]
2/2: running   [==================================================>]
verify: Service nginx-swarm converged
pwsh # docker service ps nginx-swarm
ID             NAME                IMAGE          NODE                        DESIRED STATE   CURRENT STATE             ERROR     PORTS
n58aqijknp7i   nginx-swarm.1       nginx:latest   docker-desktop              Running         Running 21 seconds ago
a2ep5adspbar    \_ nginx-swarm.1   nginx:stable   docker-desktop              Shutdown        Shutdown 22 seconds ago
4bxjqlg5hijc    \_ nginx-swarm.1   nginx:stable   ohk68o6ltovozre6gu0m7fo2s   Shutdown        Orphaned 32 minutes ago
efk75qkquzox   nginx-swarm.2       nginx:latest   docker-desktop              Running         Running 16 seconds ago
w9g2un638qpf    \_ nginx-swarm.2   nginx:stable   docker-desktop              Shutdown        Shutdown 17 seconds ago
pwsh # docker node ls
ID                            HOSTNAME         STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
nonaeff3792tk4jrjpp8w1djz *   docker-desktop   Ready     Active         Leader           27.1.1
```

# Step 4 Rollback image updates

```powershell
pwsh # docker service rollback nginx-swarm
nginx-swarm
rollback: manually requested rollback
overall progress: rolling back update: 2 out of 2 tasks
1/2: running   [==================================================>]
2/2: running   [==================================================>]
verify: Service nginx-swarm converged
pwsh # docker service ps nginx-swarm
ID             NAME                IMAGE          NODE                        DESIRED STATE   CURRENT STATE             ERROR     PORTS
01badknwp9ie   nginx-swarm.1       nginx:stable   docker-desktop              Running         Running 14 seconds ago
n58aqijknp7i    \_ nginx-swarm.1   nginx:latest   docker-desktop              Shutdown        Shutdown 15 seconds ago
a2ep5adspbar    \_ nginx-swarm.1   nginx:stable   docker-desktop              Shutdown        Shutdown 2 minutes ago
4bxjqlg5hijc    \_ nginx-swarm.1   nginx:stable   ohk68o6ltovozre6gu0m7fo2s   Shutdown        Orphaned 35 minutes ago
7qkftcznudrh   nginx-swarm.2       nginx:stable   docker-desktop              Running         Running 9 seconds ago
efk75qkquzox    \_ nginx-swarm.2   nginx:latest   docker-desktop              Shutdown        Shutdown 10 seconds ago
w9g2un638qpf    \_ nginx-swarm.2   nginx:stable   docker-desktop              Shutdown        Shutdown 2 minutes ago
```

# Step 5 Remove swarm services

> Clean up Resources

```powershell
pwsh # docker service rm nginx-swarm
nginx-swarm
```

# Previous: [Writing Docker Compose file for Multi-Container App](../ACM-06/Writing%20Docker%20Compose%20file%20for%20Multi-Container%20App.md)

# Next: [Docker Swarm Networking with Overlay Driver](../ACM-08/Docker%20Swarm%20Networking%20with%20Overlay%20Driver.md)
