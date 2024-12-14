# Assignment No 3 A

## Title: Minikube Commands

| **Command**               | **Example**                              | **Description**                                                                                   |
| ------------------------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `minikube start`          | `minikube start`                         | Starts a local Kubernetes cluster using Minikube.                                                 |
| `minikube stop`           | `minikube stop`                          | Stops the Minikube cluster, shutting down the VM or container.                                    |
| `minikube delete`         | `minikube delete`                        | Deletes the Minikube cluster, removing the VM or container.                                       |
| `minikube status`         | `minikube status`                        | Shows the status of the Minikube cluster, including the VM, cluster, and Kubernetes components.   |
| `minikube dashboard`      | `minikube dashboard`                     | Launches the Kubernetes dashboard in a web browser.                                               |
| `minikube ssh`            | `minikube ssh`                           | Opens an SSH session to the Minikube VM or container.                                             |
| `minikube ip`             | `minikube ip`                            | Returns the IP address of the Minikube cluster.                                                   |
| `minikube addons list`    | `minikube addons list`                   | Lists the available and enabled add-ons in Minikube.                                              |
| `minikube addons enable`  | `minikube addons enable metrics-server`  | Enables a specific add-on (e.g., `metrics-server`) in Minikube.                                   |
| `minikube addons disable` | `minikube addons disable metrics-server` | Disables a specific add-on in Minikube.                                                           |
| `minikube logs`           | `minikube logs`                          | Retrieves logs from the Minikube cluster for debugging purposes.                                  |
| `minikube service`        | `minikube service my-service`            | Opens the URL for a Kubernetes service in a web browser.                                          |
| `minikube tunnel`         | `minikube tunnel`                        | Creates a network tunnel to allow LoadBalancer services to be accessible on localhost.            |
| `minikube kubectl --`     | `minikube kubectl -- get pods`           | Runs `kubectl` commands against the Minikube cluster without needing a separate `kubectl` binary. |
| `minikube config set`     | `minikube config set memory 4096`        | Sets a configuration option for Minikube (e.g., memory allocation).                               |

---

### Minikube Commands Answers

```bash
minikube start
```

```sh
fish # minikube start
😄  minikube v1.34.0 on Garuda
✨  Using the docker driver based on existing profile
💨  For improved Docker performance, enable the overlay Linux kernel module using 'modprobe overlay'
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.45 ...
🔄  Restarting existing docker container for "minikube" ...
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

```bash
minikube status
```

```sh
fish # minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

```bash
minikube stop
```

```sh
fish # minikube stop
✋  Stopping node "minikube"  ...
🛑  Powering off "minikube" via SSH ...
🛑  1 node stopped.
```

```bash
minikube start
```

```sh
fish # minikube start
😄  minikube v1.34.0 on Garuda
✨  Using the docker driver based on existing profile
💨  For improved Docker performance, enable the overlay Linux kernel module using 'modprobe overlay'
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.45 ...
🔄  Restarting existing docker container for "minikube" ...
🐳  Preparing Kubernetes v1.31.0 on Docker 27.2.0 ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

```bash
minikube addons list
```

| ADDON NAME                  | PROFILE  | STATUS     | MAINTAINER                     |
| --------------------------- | -------- | ---------- | ------------------------------ |
| ambassador                  | minikube | disabled   | 3rd party (Ambassador)         |
| auto-pause                  | minikube | disabled   | minikube                       |
| cloud-spanner               | minikube | disabled   | Google                         |
| csi-hostpath-driver         | minikube | disabled   | Kubernetes                     |
| dashboard                   | minikube | disabled   | Kubernetes                     |
| default-storageclass        | minikube | enabled ✅ | Kubernetes                     |
| efk                         | minikube | disabled   | 3rd party (Elastic)            |
| freshpod                    | minikube | disabled   | Google                         |
| gcp-auth                    | minikube | disabled   | Google                         |
| gvisor                      | minikube | disabled   | minikube                       |
| headlamp                    | minikube | disabled   | 3rd party (kinvolk.io)         |
| helm-tiller                 | minikube | disabled   | 3rd party (Helm)               |
| inaccel                     | minikube | disabled   | 3rd party (InAccel             |
|                             |          |            | [info@inaccel.com])            |
| ingress                     | minikube | disabled   | Kubernetes                     |
| ingress-dns                 | minikube | disabled   | minikube                       |
| inspektor-gadget            | minikube | disabled   | 3rd party                      |
|                             |          |            | (inspektor-gadget.io)          |
| istio                       | minikube | disabled   | 3rd party (Istio)              |
| istio-provisioner           | minikube | disabled   | 3rd party (Istio)              |
| kong                        | minikube | disabled   | 3rd party (Kong HQ)            |
| kubeflow                    | minikube | disabled   | 3rd party                      |
| kubevirt                    | minikube | disabled   | 3rd party (KubeVirt)           |
| logviewer                   | minikube | disabled   | 3rd party (unknown)            |
| metallb                     | minikube | disabled   | 3rd party (MetalLB)            |
| metrics-server              | minikube | disabled   | Kubernetes                     |
| nvidia-device-plugin        | minikube | disabled   | 3rd party (NVIDIA)             |
| nvidia-driver-installer     | minikube | disabled   | 3rd party (NVIDIA)             |
| nvidia-gpu-device-plugin    | minikube | disabled   | 3rd party (NVIDIA)             |
| olm                         | minikube | disabled   | 3rd party (Operator Framework) |
| pod-security-policy         | minikube | disabled   | 3rd party (unknown)            |
| portainer                   | minikube | disabled   | 3rd party (Portainer.io)       |
| registry                    | minikube | disabled   | minikube                       |
| registry-aliases            | minikube | disabled   | 3rd party (unknown)            |
| registry-creds              | minikube | disabled   | 3rd party (UPMC Enterprises)   |
| storage-provisioner         | minikube | enabled ✅ | minikube                       |
| storage-provisioner-gluster | minikube | disabled   | 3rd party (Gluster)            |
| storage-provisioner-rancher | minikube | disabled   | 3rd party (Rancher)            |
| volcano                     | minikube | disabled   | third-party (volcano)          |
| volumesnapshots             | minikube | disabled   | Kubernetes                     |
| yakd                        | minikube | disabled   | 3rd party (marcnuri.com)       |

```bash
minikube addons enable dashboard
```

```sh
fish # minikube addons enable dashboard
💡  dashboard is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image docker.io/kubernetesui/dashboard:v2.7.0
    ▪ Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
💡  Some dashboard features require the metrics-server addon. To enable all features please run:

	minikube addons enable metrics-server

🌟  The 'dashboard' addon is enabled
fish # minikube dashboard
🤔  Verifying dashboard health ...
🚀  Launching proxy ...
🤔  Verifying proxy health ...
🎉  Opening http://127.0.0.1:33645/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/ in your default browser...
```

```bash
minikube addons enable metrics-server
```

```sh
fish # minikube addons enable metrics-server
💡  metrics-server is an addon maintained by Kubernetes. For any concerns contact minikube on GitHub.
You can view the list of minikube maintainers at: https://github.com/kubernetes/minikube/blob/master/OWNERS
    ▪ Using image registry.k8s.io/metrics-server/metrics-server:v0.7.2
🌟  The 'metrics-server' addon is enabled
```

```bash
alias kctl=kubectl
```

```bash
kctl top po-A
```

```sh
fish # kubectl top pod -A
NAMESPACE              NAME                                        CPU(cores)   MEMORY(bytes)
kube-system            coredns-6f6b679f8f-j2vl5                    2m           23Mi
kube-system            etcd-minikube                               14m          56Mi
kube-system            kube-apiserver-minikube                     26m          210Mi
kube-system            kube-controller-manager-minikube            12m          62Mi
kube-system            kube-proxy-4gwzl                            1m           20Mi
kube-system            kube-scheduler-minikube                     2m           23Mi
kube-system            metrics-server-84c5f94fbc-9k7tk             3m           17Mi
kube-system            storage-provisioner                         2m           19Mi
kubernetes-dashboard   dashboard-metrics-scraper-c5db448b4-z2ddh   1m           6Mi
kubernetes-dashboard   kubernetes-dashboard-695b96c756-9mlkd       1m           36Mi
```