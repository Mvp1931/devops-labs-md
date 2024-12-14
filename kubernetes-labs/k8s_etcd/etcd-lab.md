# Manage Etcd Cluster in Kubernetes

### `ETCD` is a highly available distributed key-value store often used as the Backend for critical systems like Kubernetes. It provide strong consistency, reliable leader election, and automatic failover.

minikube does not come with etcd installed by default. You can install etcd with helm:

```bash
fish # helm repo add bitnami https://charts.bitnami.com/bitnami
"bitnami" has been added to your repositories
fish # helm install bitnami-etcd bitnami/etcd
NAME: bitnami-etcd
LAST DEPLOYED: Wed Nov 20 22:15:56 2024
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: etcd
CHART VERSION: 10.5.3
APP VERSION: 3.5.17

** Please be patient while the chart is being deployed **

etcd can be accessed via port 2379 on the following DNS name from within your cluster:

    bitnami-etcd.default.svc.cluster.local

To create a pod that you can use as a etcd client run the following command:

    kubectl run bitnami-etcd-client --restart='Never' --image docker.io/bitnami/etcd:3.5.17-debian-12-r0 --env ROOT_PASSWORD=$(kubectl get secret --namespace default bitnami-etcd -o jsonpath="{.data.etcd-root-password}" | base64 -d) --env ETCDCTL_ENDPOINTS="bitnami-etcd.default.svc.cluster.local:2379" --namespace default --command -- sleep infinity

Then, you can set/get a key using the commands below:

    kubectl exec --namespace default -it bitnami-etcd-client -- bash
    etcdctl --user root:$ROOT_PASSWORD put /message Hello
    etcdctl --user root:$ROOT_PASSWORD get /message

To connect to your etcd server from outside the cluster execute the following commands:

    kubectl port-forward --namespace default svc/bitnami-etcd 2379:2379 &
    echo "etcd URL: http://127.0.0.1:2379"

 * As rbac is enabled you should add the flag `--user root:$ETCD_ROOT_PASSWORD` to the etcdctl commands. Use the command below to export the password:

    export ETCD_ROOT_PASSWORD=$(kubectl get secret --namespace default bitnami-etcd -o jsonpath="{.data.etcd-root-password}" | base64 -d)

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - disasterRecovery.cronjob.resources
  - resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
```

Run the etcd cluster on local machine

```bash
fish # kubectl port-forward -n bitnami services/bitnami-etcd 2379:2379
Forwarding from 127.0.0.1:2379 -> 2379
Forwarding from [::1]:2379 -> 2379
Handling connection for 2379
...
```

### Configuring Etcd:

You can customize the Etcd deployment using Helm values:

```Bash
helm install my-etcd bitnami/etcd -f values.yaml
# Use code with caution.
```

-   In the `values.yaml` file, you can configure:

    -   **Image**: Specify the desired Etcd image and version.
    -   **Replicas**: Set the number of Etcd server replicas.
    -   **Persistence**: Configure persistent storage for Etcd data.
    -   **Security**: Enable TLS and authentication mechanisms.
    -   **Cluster Configuration**: Specify the initial cluster state and peer URLs.

-   Managing Etcd with Helm:

_Upgrade_:

```Bash
helm upgrade my-etcd bitnami/etcd
# Use code with caution.
```

_Rollback_:

```Bash
helm rollback my-etcd <REVISION>
 # Use code with caution.
```

_Delete_:

```Bash
helm delete my-etcd
# Use code with caution.
```

#### Additional Considerations:

-   **Security**: Ensure proper security measures, including TLS and authentication, to protect your Etcd cluster.
-   **High Availability**: Configure a sufficient number of replicas to achieve high availability.
-   **Backup and Restore**: Implement a backup and restore strategy for your Etcd data.
-   **Monitoring**: Monitor Etcd's health and performance using tools like Prometheus and Grafana.
