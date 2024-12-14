# EFK Stack for Kubernetes Logging

The EFK stack is a popular combination of tools for collecting, aggregating, and analyzing logs in Kubernetes:

-   Elasticsearch: A distributed, scalable search and analytics engine for storing and searching logs.
-   Fluentd: A log collector that can collect logs from various sources, including Kubernetes pods, and forward them to Elasticsearch.
-   Kibana: A powerful visualization tool for exploring and analyzing logs stored in Elasticsearch.
    Minikube and EFK Stack

To enable the EFK stack in Minikube, you can use the `minikube addons enable metrics-server` command. However, this primarily enables metrics collection. For full-fledged EFK logging, you'll need to deploy the EFK stack components manually or use a Helm chart.

### Manual Deployment:

-   Deploy Elasticsearch:

    -   Create a Deployment and Service for Elasticsearch.
        Configure persistent storage for Elasticsearch data.
        Deploy Fluentd:

-   Create a DaemonSet for Fluentd to run on each node.

    -   Configure Fluentd to collect logs from Kubernetes pods and forward t hem to Elasticsearch.

-   Deploy Kibana:

    -   Create a Deployment and Service for Kibana. Configure Kibana to connect to the Elasticsearch cluster.

## Using Helm Chart:

A more convenient approach is to use a Helm chart like the Bitnami EFK chart. This chart simplifies the deployment process and provides pre-configured configurations:

1. Add the Bitnami Chart Repository:

```Bash
helm repo add bitnami https://charts.bitnami.com/bitnami
# Use code with caution.
```

2. Install the EFK Chart:

```Bash
helm install my-efk bitnami/efk
# Use code with caution.
```

### How EFK Works:

-   **Log Collection**: Fluentd runs as a DaemonSet on each node in the cluster. It collects logs from various sources, including Kubernetes pods, and forwards them to Elasticsearch.
-   **Log Storage and Indexing**: Elasticsearch stores and indexes the logs, making them searchable and analyzable.
-   **Log Visualization**: Kibana provides a user-friendly interface to visualize and analyze logs. You can create custom dashboards, search for specific logs, and gain insights into the behavior of your applications.

By using the EFK stack, you can effectively monitor and troubleshoot your Kubernetes applications.
