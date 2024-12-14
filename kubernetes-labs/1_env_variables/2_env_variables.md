# Topics:

# 1. Define an environment variable for a container

When you create a Pod, you can set environment variables for the containers that run in the Pod. To set environment variables, include the `env` or `envFrom` field in the configuration file.

The env and envFrom fields have different effects.

-   **`env`**
    allows you to set environment variables for a container, specifying a value directly for each variable that you name.
-   **`envFrom`**
    Allows you to set environment variables for a container by referencing either a ConfigMap or a Secret. When you use envFrom, all the key-value pairs in the referenced ConfigMap or Secret are set as environment variables for the container. You can also specify a common prefix string.

## DEMO of Env Varaibles:

create a file called `env_variables.yml`

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
          env:
              - name: fname
                value: Vishal
              - name: lname
                value: Meshram
```

1. Create a Pod based on that manifest:

```bash
fish # kubectl apply -f env_variables.yml
pod/firstpod created
```

2. List the running Pods:

```bash
fish # kubectl get pods
NAME       READY   STATUS    RESTARTS   AGE
firstpod   1/1     Running   0          18s
```

3. List the Pod's container environment variables:

```bash
fish # kubectl exec firstpod -- env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=firstpod
fname=mihir
lname=phadnis
KUBERNETES_PORT=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_PORT_HTTPS=443
NGINX_VERSION=1.27.2
NJS_VERSION=0.8.6
NJS_RELEASE=1~bookworm
PKG_RELEASE=1~bookworm
DYNPKG_RELEASE=1~bookworm
HOME=/root
```

4. If you have multiple containers in the pod then use the following command to check the
   env variables in speciifc containers:

```bash
kubectl exec <pod_name> -c <container_name> -- env
kubectl exec firstpod -c firstcontainer -- env
```

> **_NOTE:_** The environment variables set using the env or envFrom field override any environment variables specified in the container image.

# 2. Run commands in the POD's Container

if you want to run the commands inside the container, use the following command:
If you have only one running container then the commands will run inside that container.

```bash
kubectl exec <podname> -- <command>
kubectl exec --stdin --tty firstpod -- /bin/bash
```

If you have mulitple running container use the following command:

```bash
kubectl exec <podname> -c <containername> -- <command>
kubectl exec --stdin --tty firstpod -c firstcontainer -- /bin/bash
```

> **_NOTE:_** The double dash (--) separates the arguments you want to pass to the command from the kubectl arguments.

In your shell, list the root directory:

```bash
# Run this inside the container
ls /
kubectl exec firstpod -- ls /
kubectl exec firstpod -- apt-update

# You can run these example commands inside the container
ls /
cat /proc/mounts
cat /proc/1/maps
apt-get update
apt-get install -y tcpdump
tcpdump
apt-get install -y lsof
lsof
apt-get install -y procps
ps aux
ps aux | grep nginx
```

```bash
fish # kubectl exec --stdin --tty firstpod -- /bin/bash
root@firstpod:/# ls
bin  boot  dev  docker-entrypoint.d  docker-entrypoint.sh  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@firstpod:/# ls /
bin  boot  dev  docker-entrypoint.d  docker-entrypoint.sh  etc  home  lib  lib64  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@firstpod:/# apt-update
bash: apt-update: command not found
root@firstpod:/# apk-update
bash: apk-update: command not found
root@firstpod:/# cat /proc/mounts
overlay / overlay rw,relatime,lowerdir=/var/lib/docker/overlay2/l/NDIKCDRFACPMDA5QDHR3X76GBB:/var/lib/docker/overlay2/l/6QY6Z5JKIDLNGGI45NRNHQKSXQ:/var/lib/docker/overlay2/l/5ABVFMRZHYLQ5VFOQGTJKFZX2P:/var/lib/docker/overlay2/l/THD4IOQ6UJVZUMFN7RKKBXS7Z7:/var/lib/docker/overlay2/l/3Y5NVA5Q6XKTY7W4C4ENOV7G4C:/var/lib/docker/overlay2/l/ZYU7ZV6SG4N3Y367QLGGPXX2W7:/var/lib/docker/overlay2/l/6ICUPHF4EMJXTXGGXKTB3VUIWT:/var/lib/docker/overlay2/l/A5V7EZTMKY6LIMM72DTWDL5QSO,upperdir=/var/lib/docker/overlay2/0980d5236be0deee1be1a25387fa06a05e6ce1a9dce84c0d0d999dd52773833d/diff,workdir=/var/lib/docker/overlay2/0980d5236be0deee1be1a25387fa06a05e6ce1a9dce84c0d0d999dd52773833d/work 0 0
proc /proc proc rw,nosuid,nodev,noexec,relatime 0 0
tmpfs /dev tmpfs rw,nosuid,size=65536k,mode=755 0 0
devpts /dev/pts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=666 0 0
sysfs /sys sysfs ro,nosuid,nodev,noexec,relatime 0 0
cgroup /sys/fs/cgroup cgroup2 ro,nosuid,nodev,noexec,relatime 0 0
mqueue /dev/mqueue mqueue rw,nosuid,nodev,noexec,relatime 0 0
shm /dev/shm tmpfs rw,nosuid,nodev,noexec,relatime,size=65536k 0 0
/dev/vda1 /dev/termination-log ext4 rw,relatime,discard 0 0
/dev/vda1 /etc/resolv.conf ext4 rw,relatime,discard 0 0
/dev/vda1 /etc/hostname ext4 rw,relatime,discard 0 0
/dev/vda1 /etc/hosts ext4 rw,relatime,discard 0 0
tmpfs /run/secrets/kubernetes.io/serviceaccount tmpfs ro,relatime,size=3883228k,noswap 0 0
proc /proc/bus proc ro,nosuid,nodev,noexec,relatime 0 0
proc /proc/fs proc ro,nosuid,nodev,noexec,relatime 0 0
proc /proc/irq proc ro,nosuid,nodev,noexec,relatime 0 0
proc /proc/sys proc ro,nosuid,nodev,noexec,relatime 0 0
proc /proc/sysrq-trigger proc ro,nosuid,nodev,noexec,relatime 0 0
tmpfs /proc/acpi tmpfs ro,relatime 0 0
tmpfs /proc/kcore tmpfs rw,nosuid,size=65536k,mode=755 0 0
tmpfs /proc/keys tmpfs rw,nosuid,size=65536k,mode=755 0 0
tmpfs /proc/timer_list tmpfs rw,nosuid,size=65536k,mode=755 0 0
tmpfs /sys/firmware tmpfs ro,relatime 0 0
root@firstpod:/# cat /proc/1/maps
5654ad570000-5654ad59f000 r--p 00000000 00:eb 2102171                    /usr/sbin/nginx
5654ad59f000-5654ad68d000 r-xp 0002f000 00:eb 2102171                    /usr/sbin/nginx
5654ad68d000-5654ad6cc000 r--p 0011d000 00:eb 2102171                    /usr/sbin/nginx
5654ad6cc000-5654ad6cf000 r--p 0015c000 00:eb 2102171                    /usr/sbin/nginx
5654ad6cf000-5654ad6ee000 rw-p 0015f000 00:eb 2102171                    /usr/sbin/nginx
5654ad6ee000-5654ad7ad000 rw-p 00000000 00:00 0
5654cb92a000-5654cb9ad000 rw-p 00000000 00:00 0                          [heap]
7f7cd9c1f000-7f7cd9c45000 r--p 00000000 00:eb 2098150                    /usr/lib/x86_64-linux-gnu/libc.so.6
7f7cd9c45000-7f7cd9d9a000 r-xp 00026000 00:eb 2098150                    /usr/lib/x86_64-linux-gnu/libc.so.6
7f7cd9d9a000-7f7cd9ded000 r--p 0017b000 00:eb 2098150                    /usr/lib/x86_64-linux-gnu/libc.so.6
7f7cd9ded000-7f7cd9df1000 r--p 001ce000 00:eb 2098150                    /usr/lib/x86_64-linux-gnu/libc.so.6
7f7cd9df1000-7f7cd9df3000 rw-p 001d2000 00:eb 2098150                    /usr/lib/x86_64-linux-gnu/libc.so.6
7f7cd9df3000-7f7cd9e00000 rw-p 00000000 00:00 0
7f7cd9e00000-7f7cd9ec5000 r--p 00000000 00:eb 2102076                    /usr/lib/x86_64-linux-gnu/libcrypto.so.3
7f7cd9ec5000-7f7cda141000 r-xp 000c5000 00:eb 2102076                    /usr/lib/x86_64-linux-gnu/libcrypto.so.3
7f7cda141000-7f7cda21f000 r--p 00341000 00:eb 2102076                    /usr/lib/x86_64-linux-gnu/libcrypto.so.3
7f7cda21f000-7f7cda280000 r--p 0041f000 00:eb 2102076                    /usr/lib/x86_64-linux-gnu/libcrypto.so.3
7f7cda280000-7f7cda283000 rw-p 00480000 00:eb 2102076                    /usr/lib/x86_64-linux-gnu/libcrypto.so.3
7f7cda283000-7f7cda286000 rw-p 00000000 00:00 0
7f7cda38c000-7f7cda391000 rw-p 00000000 00:00 0
7f7cda391000-7f7cda394000 r--p 00000000 00:eb 2098249                    /usr/lib/x86_64-linux-gnu/libz.so.1.2.13
7f7cda394000-7f7cda3a7000 r-xp 00003000 00:eb 2098249                    /usr/lib/x86_64-linux-gnu/libz.so.1.2.13
7f7cda3a7000-7f7cda3ae000 r--p 00016000 00:eb 2098249                    /usr/lib/x86_64-linux-gnu/libz.so.1.2.13
7f7cda3ae000-7f7cda3af000 r--p 0001c000 00:eb 2098249                    /usr/lib/x86_64-linux-gnu/libz.so.1.2.13
7f7cda3af000-7f7cda3b0000 rw-p 0001d000 00:eb 2098249                    /usr/lib/x86_64-linux-gnu/libz.so.1.2.13
7f7cda3b0000-7f7cda3cf000 r--p 00000000 00:eb 2102146                    /usr/lib/x86_64-linux-gnu/libssl.so.3
7f7cda3cf000-7f7cda42c000 r-xp 0001f000 00:eb 2102146                    /usr/lib/x86_64-linux-gnu/libssl.so.3
7f7cda42c000-7f7cda44b000 r--p 0007c000 00:eb 2102146                    /usr/lib/x86_64-linux-gnu/libssl.so.3
7f7cda44b000-7f7cda455000 r--p 0009a000 00:eb 2102146                    /usr/lib/x86_64-linux-gnu/libssl.so.3
7f7cda455000-7f7cda459000 rw-p 000a4000 00:eb 2102146                    /usr/lib/x86_64-linux-gnu/libssl.so.3
7f7cda459000-7f7cda45b000 r--p 00000000 00:eb 2098213                    /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0.11.2
7f7cda45b000-7f7cda4c6000 r-xp 00002000 00:eb 2098213                    /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0.11.2
7f7cda4c6000-7f7cda4f1000 r--p 0006d000 00:eb 2098213                    /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0.11.2
7f7cda4f1000-7f7cda4f2000 r--p 00098000 00:eb 2098213                    /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0.11.2
7f7cda4f2000-7f7cda4f3000 rw-p 00099000 00:eb 2098213                    /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0.11.2
7f7cda4f3000-7f7cda4f5000 r--p 00000000 00:eb 2098159                    /usr/lib/x86_64-linux-gnu/libcrypt.so.1.1.0
7f7cda4f5000-7f7cda50b000 r-xp 00002000 00:eb 2098159                    /usr/lib/x86_64-linux-gnu/libcrypt.so.1.1.0
7f7cda50b000-7f7cda525000 r--p 00018000 00:eb 2098159                    /usr/lib/x86_64-linux-gnu/libcrypt.so.1.1.0
7f7cda525000-7f7cda526000 r--p 00031000 00:eb 2098159                    /usr/lib/x86_64-linux-gnu/libcrypt.so.1.1.0
7f7cda526000-7f7cda527000 rw-p 00032000 00:eb 2098159                    /usr/lib/x86_64-linux-gnu/libcrypt.so.1.1.0
7f7cda527000-7f7cda52f000 rw-p 00000000 00:00 0
7f7cda532000-7f7cda533000 rw-s 00000000 00:01 1040                       /dev/zero (deleted)
7f7cda533000-7f7cda535000 rw-p 00000000 00:00 0
7f7cda535000-7f7cda539000 r--p 00000000 00:00 0                          [vvar]
7f7cda539000-7f7cda53b000 r-xp 00000000 00:00 0                          [vdso]
7f7cda53b000-7f7cda53c000 r--p 00000000 00:eb 2098132                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7f7cda53c000-7f7cda561000 r-xp 00001000 00:eb 2098132                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7f7cda561000-7f7cda56b000 r--p 00026000 00:eb 2098132                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7f7cda56b000-7f7cda56d000 r--p 00030000 00:eb 2098132                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7f7cda56d000-7f7cda56f000 rw-p 00032000 00:eb 2098132                    /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
7fffa88c6000-7fffa88e7000 rw-p 00000000 00:00 0                          [stack]
ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
root@firstpod:/# apk
bash: apk: command not found
root@firstpod:/# exit
```

# 3. CMD and ENTRYPOINT in Kubernets

## Define a command and arguments when you create a Pod

When you create a Pod, you can define a command and arguments for the containers that run in the Pod. To define a command, include the command field in the configuration file. To define arguments for the command, include the args field in the configuration file. The command and arguments that you define cannot be changed after the Pod is created.

The command and arguments that you define in the configuration file override the default command and arguments provided by the container image. If you define args, but do not define a command, the default command is used with your new arguments.

> **_NOTE:_** The `command` field corresponds to `ENTRYPOINT`, and the `args` field corresponds to `CMD` in some container runtimes.

Example:

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: command-demo
    labels:
        purpose: demonstrate-command
spec:
    containers:
        - name: command-demo-container
          image: debian
          command: ["printenv"]
          args: ["HOSTNAME", "KUBERNETES_PORT"]
    restartPolicy: OnFailure
```
