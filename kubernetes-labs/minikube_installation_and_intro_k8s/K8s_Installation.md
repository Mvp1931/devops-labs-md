> [Go to Home](../kubernetes-labs.md)

# Assignment No 1:

## Title: Kubernetes Installation

### 1. Overview of Kubernets Installation Methods\*\*

Kubernetes can be installed on different platforms using various methods. The most common ones are:

-   **Minikube:** A lightweight Kubernetes implementation that creates a VM on your local machine and deploys a simple cluster.
-   **Docker Desktop with Kubernetes:** If Docker is already installed, Kubernetes can be enabled directly within Docker Desktop.
-   **K3s:** A lightweight Kubernetes distribution designed for IoT and edge computing but works great for development.
-   **MicroK8s:** A minimal, lightweight Kubernetes distribution developed by Canonical.

For Windows, we'll focus on using Docker Desktop and Minikube.

### 2. Enabling Kubernetes on Docker Desktop

Since Docker is already installed on your Windows 10 machine, this method is the easiest.

**Steps:**

1. Open Docker Desktop: Start Docker Desktop if it's not already running.

2. Enable Kubernetes:

-   Click on the Docker icon in your system tray (bottom-right corner).
-   Select Settings.
-   In the Settings menu, select Kubernetes from the left-hand panel.
-   Check the box "Enable Kubernetes".
-   Click on Apply & Restart.
-   Docker Desktop will now start installing Kubernetes components. This might take a few minutes.

3. Verify Installation:

-   Open Command Prompt or PowerShell.
-   Run the command: kubectl version --client
-   You should see output indicating the version of kubectl, which is the command-line tool for interacting with Kubernetes.

4. Testing the Installation:

-   Run: kubectl get nodes
-   This should list the nodes in your cluster, and you should see a single node corresponding to your local machine.

### 3. Installing Kubernetes via Minikube

If you prefer using Minikube, here's how to set it up:

**Prerequisites:**
Hyper-V or VirtualBox: Minikube requires a hypervisor to create a virtual machine. On Windows, Hyper-V or VirtualBox are commonly used. If you're using Hyper-V, ensure it's enabled from the Windows Features settings.

**Steps:**
**1. Install Minikube:**

[Download Minikube from the official Minikube releases page.](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download)

Alternatively, you can use the command line to install it via choco (Chocolatey):

```powershell
choco install minikube
```

**2. Start Minikube:**

Open Command Prompt or PowerShell.
Start Minikube with:

```bash
minikube start --driver=hyperv
```

Replace` --driver=hyperv` with `--driver=virtualbox` if you're using VirtualBox.

> Note, we are using minikube with docker driver. so, first make sure you have docker installed on your machine.
> And start minikube with docker driver.

```bash
minikube start --driver=docker
```

**3. Verify Installation:**

-   Run: **`kubectl get nodes`**
-   You should see a single node running in your Minikube cluster.

### 4. Installing Kubernetes on Linux and macOS

For Linux and macOS, the process is quite similar. Minikube and Docker Desktop are available on both platforms, with slight variations in setup.
