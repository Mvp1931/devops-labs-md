> [Go to Home](../docker-labs.md)

1. Initialize docker swarm

```powershell
pwsh # docker swarm init
Swarm initialized: current node (mfp1lb6wlysk4peegqwbgtoc7) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-4o1sloxosku4k6majqzpwji4y4tbiebgrlqq8ohyoqor7tujh1-58kushqa1hgcccyycgf5klwv8 192.168.65.3:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

2. Create a docker secrets file to store MySQL root password. create a docker secret with `docker secret` command.

```powershell
pwsh # echo "secret_mysql" > db_password.txt
pwsh # docker secret create db_password db_password.txt
qkvfxkq71kebrsjih0x3901kw
```

3. Deploy MySQL service with secrets.

```powershell
pwsh # docker service create `
> --name mysql_service `
> --secret db_password `
> --env MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_password `
> mysql:8.0
2xfh71a1tfchfi7m8czg1j7kc
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service 2xfh71a1tfchfi7m8czg1j7kc converged
pwsh # docker service ls
ID             NAME            MODE         REPLICAS   IMAGE       PORTS
2xfh71a1tfch   mysql_service   replicated   1/1        mysql:8.0
```

4. .Verify secret inside service.

```powershell
pwsh # docker service ls
ID             NAME            MODE         REPLICAS   IMAGE       PORTS
2xfh71a1tfch   mysql_service   replicated   1/1        mysql:8.0
pwsh # docker ps -a
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                 NAMES
5d5b11df7918   mysql:8.0   "docker-entrypoint.s…"   5 minutes ago   Up 5 minutes   3306/tcp, 33060/tcp   mysql_service.1.jxgx506c21le7335phmgn1v0y
pwsh # docker exec -it 5d5b /bin/bash
bash-5.1# cat /run/secrets/db_password
secret_mysql
bash-5.1# exit
exit
```

5. check if MySQL Works...

```powershell
pwsh # docker exec -it 5d5b mysql -u root -p
Enter password:
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
```

_it does not...._ 6. Updating the password secret (by creating new secret and replacing old with new one).

```powershell
pwsh # docker service update `
> --secret-rm db_password `
> --secret-add source=db_password_v2,target=db_password `
> mysql_service
mysql_service
overall progress: 1 out of 1 tasks
1/1: running   [==================================================>]
verify: Service mysql_service converged

pwsh # docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED          STATUS          PORTS                 NAMES
2430088fc339   mysql:8.0   "docker-entrypoint.s…"   41 seconds ago   Up 38 seconds   3306/tcp, 33060/tcp   mysql_service.1.f4m68s0aagoi7ojxnwpl9mjmj
pwsh # docker exec -it 2430 /bin/bash
bash-5.1# cat /run/secrets/db_password
new_secret_mysql
bash-5.1# mysql -u root -p mew_secret_mysql
Enter password:
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
bash-5.1# exit
exit
```

_Here, you can see old container has been destroyed and new container is created for service relaunch._ 7. removing the secret

```powershell
pwsh # docker service ls
ID             NAME            MODE         REPLICAS   IMAGE       PORTS
2xfh71a1tfch   mysql_service   replicated   1/1        mysql:8.0
pwsh # docker service rm 2xfh
2xfh
pwsh # docker secret rm db_password
db_password
pwsh # docker secret rm db_password_v2
db_password_v2
```

# Previous: [Docker Swarm Networking with Overlay Driver](../ACM-08/Docker%20Swarm%20Networking%20with%20Overlay%20Driver.md)
