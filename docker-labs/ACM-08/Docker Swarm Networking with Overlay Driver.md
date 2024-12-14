> [Go to Home](../docker-labs.md)

> The objective of this assignment is to understand and demonstrate Docker Swarm networking using the overlay driver. You will create two different services, nginx and mysql, connect them to an overlay network, and demonstrate that they can communicate with each other.

1. Run `docker swarm init` to start swarm manager in current window: docker desktop.

```powershell
pwsh # docker swarm init
Swarm initialized: current node (nkrku2ak26fvk9rxy6j5kwg5q) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-0ouciti7dqpq566y14r8e0fvj9x46j48qnge0l5b3m5wkfwv16-dg8amxf46roetow00kib91me8 192.168.65.3:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

2. create _2_ worker nodes and join them to manager with `docker swarm join --token...` command. Verify them with `docker node ls` command.

```powershell
pwsh # docker run -d --privileged --name worker1 --hostname=worker1 docker:dind
fd242c5f09fbbcdd60a238fc178e09f0351f7d9e9af2e527c37f8df2a00caa77
pwsh # docker run -d --privileged --name worker2 --hostname=worker2 docker:dind
eb6a79524f047c6a8fc4a2836a7d98dc1ffe2e793eabd36bef5deda846fe221d

pwsh # docker exec -it worker1 `
> docker swarm join --token SWMTKN-1-0ouciti7dqpq566y14r8e0fvj9x46j48qnge0l5b3m5wkfwv16-dg8amxf46roetow00kib91me8 192.168.65.3:2377
This node joined a swarm as a worker.

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug worker1
    Learn more at https://docs.docker.com/go/debug-cli/

pwsh # docker exec -it worker2 `
> docker swarm join --token SWMTKN-1-0ouciti7dqpq566y14r8e0fvj9x46j48qnge0l5b3m5wkfwv16-dg8amxf46roetow00kib91me8 192.168.65.3:2377
This node joined a swarm as a worker.

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug worker2
    Learn more at https://docs.docker.com/go/debug-cli/

pwsh # docker node ls
ID                            HOSTNAME         STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
nkrku2ak26fvk9rxy6j5kwg5q *   docker-desktop   Ready     Active         Leader           27.1.1
3es83hdypb7h7713gprdgxl45     worker1          Ready     Active                          27.1.2
roe7c513cbznwlxav2olvrtsa     worker2          Ready     Active                          27.1.2
```

3. Create **Overlay** Network

```powershell
pwsh # docker network create --driver=overlay --attachable swarm_overlay
gp6hl7bkm37glq5q9ljalwq6q
```

4. Deploy Nginx and MySQL services in Swarm with overlay network.

```powershell
pwsh # docker service create --name my_nginx --network swarm_overlay nginx
2uzlekp2cer29ro531t6bdbvk
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service 2uzlekp2cer29ro531t6bdbvk converged

pwsh # docker service create --name mysql_swarm --network swarm_overlay `
> -e MYSQL_ROOT_PASSWORD=secret `
> mysql:8.0
jrckz1d7zzr92e7x39i1uftzx
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service jrckz1d7zzr92e7x39i1uftzx converged
```

5. Verify communication is established between service by launching a service in the network.

```powershell
pwsh # docker run -itd `
> --network swarm_overlay `
> alpine `
> /bin/sh
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
c6a83fedfae6: Already exists
Digest: sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5
Status: Downloaded newer image for alpine:latest
7b09e04b2c1880275c931d210dfbf991a03cdf161ce1865d12c185fd098248e0
pwsh # docker exec -it 7b09 /bin/sh
/ # wwhoami
/bin/sh: wwhoami: not found
/ # whoami
root
/ # ping my_nginx
PING my_nginx (10.0.1.2): 56 data bytes
64 bytes from 10.0.1.2: seq=0 ttl=64 time=0.106 ms
64 bytes from 10.0.1.2: seq=1 ttl=64 time=0.074 ms
64 bytes from 10.0.1.2: seq=2 ttl=64 time=0.050 ms
64 bytes from 10.0.1.2: seq=3 ttl=64 time=0.047 ms
64 bytes from 10.0.1.2: seq=4 ttl=64 time=0.050 ms
64 bytes from 10.0.1.2: seq=5 ttl=64 time=0.049 ms
64 bytes from 10.0.1.2: seq=6 ttl=64 time=0.052 ms
^C
--- my_nginx ping statistics ---
7 packets transmitted, 7 packets received, 0% packet loss
round-trip min/avg/max = 0.047/0.061/0.106 ms
/ # ping mysql_swarm
PING mysql_swarm (10.0.1.5): 56 data bytes
64 bytes from 10.0.1.5: seq=0 ttl=64 time=0.087 ms
64 bytes from 10.0.1.5: seq=1 ttl=64 time=0.045 ms
64 bytes from 10.0.1.5: seq=2 ttl=64 time=0.050 ms
64 bytes from 10.0.1.5: seq=3 ttl=64 time=0.055 ms
64 bytes from 10.0.1.5: seq=4 ttl=64 time=0.063 ms
^C
--- mysql_swarm ping statistics ---
5 packets transmitted, 5 packets received, 0% packet loss
round-trip min/avg/max = 0.045/0.060/0.087 ms
/ # exit

What's next:
    Try Docker Debug for seamless, persistent debugging tools in any container or image → docker debug 7b09
    Learn more at https://docs.docker.com/go/debug-cli/
```

6. Clean up
    1. remove services, nodes, leave swarm and remove network.

```powershell
pwsh # docker service ls
ID             NAME          MODE         REPLICAS   IMAGE          PORTS
2uzlekp2cer2   my_nginx      replicated   1/1        nginx:latest
jrckz1d7zzr9   mysql_swarm   replicated   1/1        mysql:8.0
pwsh # docker service rm 2uzl jrck
2uzl
jrck
pwsh # docker network ls
NETWORK ID     NAME              DRIVER    SCOPE
1dba52cd44ab   bridge            bridge    local
85c6d0a28b83   docker_gwbridge   bridge    local
d78464cb6484   host              host      local
zcosso9xenn0   ingress           overlay   swarm
f00f230b2960   none              null      local
gp6hl7bkm37g   swarm_overlay     overlay   swarm
pwsh # docker node

Usage:  docker node COMMAND

Manage Swarm nodes

Commands:
  demote      Demote one or more nodes from manager in the swarm
  inspect     Display detailed information on one or more nodes
  ls          List nodes in the swarm
  promote     Promote one or more nodes to manager in the swarm
  ps          List tasks running on one or more nodes, defaults to current node
  rm          Remove one or more nodes from the swarm
  update      Update a node

Run 'docker node COMMAND --help' for more information on a command.
pwsh # docker node ls
ID                            HOSTNAME         STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
zdesn51qiympj5896yk508ops *   docker-desktop   Ready     Active         Leader           27.1.1
7koezpij3xph6z8oq3zmf06r6     worker1          Ready     Active                          27.1.2
xpdbzyv931h3lymfczm52ctgt     worker2          Ready     Active                          27.1.2
pwsh # docker swarm leave --force
Node left the swarm.
pwsh # dockr ps
dockr: The term 'dockr' is not recognized as a name of a cmdlet, function, script file, or executable program.
Check the spelling of the name, or if a path was included, verify that the path is correct and try again.
pwsh # docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS           NAMES
7b09e04b2c18   alpine        "/bin/sh"                6 minutes ago    Up 6 minutes                    condescending_elgamal
2308e099014c   docker:dind   "dockerd-entrypoint.…"   21 minutes ago   Up 21 minutes   2375-2376/tcp   worker2
e361365d4fb1   docker:dind   "dockerd-entrypoint.…"   21 minutes ago   Up 21 minutes   2375-2376/tcp   worker1
pwsh # $containerIds = docker ps -aq
pwsh # $containerIds | ForEach-Object {docker stop $_}
7b09e04b2c18
2308e099014c
e361365d4fb1
pwsh # $containerIds | ForEach-Object {docker rm $_}
7b09e04b2c18
2308e099014c
e361365d4fb1
pwsh # docker network ls
NETWORK ID     NAME              DRIVER    SCOPE
1dba52cd44ab   bridge            bridge    local
85c6d0a28b83   docker_gwbridge   bridge    local
d78464cb6484   host              host      local
f00f230b2960   none              null      local
pwsh # docker network rm 85c6
85c6
```

# Previous: [Manage Services Clusters with Docker Swarm](../ACM-07/Manage%20Services%20Clusters%20with%20Docker%20Swarm.md)

# Next: [Manage Secrets with Docker Swarm](../ACM-09/Manage%20Secrets%20with%20Docker%20Swarm.md)
