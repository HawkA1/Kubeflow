# Kubeflow Documentation

## Table of Contents

<!-- toc -->

- [Overview](#overview)
- [Cluster environment](#cluster-environment)
- [Kubeflow components](#kubeflow-components)
- [Kubeflow Installation](#kubeflow-installation)
  * [Prerequisites](#prerequisites)
  * [Kubernetes Installation](#kubernetes-installation)
  * [Kubernetes Storage](#kubernetes-storage)
  * [Docker Registry](#docker-registry)
  * [Install with a single command](#install-with-a-single-command)
  * [Install individual components](#install-individual-components)
- [Kubeflow Authentication Architecture](#kubeflow-authentication-architecture)
- [Kubeflow Workflow Architecture](#kubeflow-workflow-architecture)
- [Spark on Kubernetes](#spark-on-kubernetes)

<!-- tocstop -->

## Overview
This documentation is for anyone trying to setup a machine learning environment with [Kubeflow](https://www.kubeflow.org/docs/started/introduction/) and [Apache Spark](https://spark.apache.org/docs/latest/running-on-kubernetes.html) on [Kubernetes](https://kubernetes.io/docs/home/) based environment fo machine learning using [Kubeflow](https://www.kubeflow.org/docs/started/introduction/).

The Kubeflow project is dedicated to making deployments of machine learning (ML) workflows on Kubernetes simple, portable and scalable. Kubeflow is a platform for data scientists who want to build and experiment with ML pipelines. Kubeflow is also for ML engineers and operational teams who want to deploy ML systems to various environments for development, testing, and production-level serving.

## Cluster environment
For this project environment we used:
- 3 Ubuntu 22.04 Servers. 
- 3 VMs with Intel(R) Core (TM) i7-4790 CPU @ 3.60GHz and 16GB RAM DDR3.
- `Master node IP:` 192.168.0.111
- `Worker1 node IP:` 192.168.0.169
- `Worker2 node IP:` 192.168.1.35

## Kubeflow components
This section introduce every Kubeflow componenets and their utilities.

#### Central Dashboard
The Kubeflow deployment includes a central dashboard that provides quick access to the Kubeflow components deployed in your cluster.
![image](https://user-images.githubusercontent.com/75808939/206497278-277322b2-741f-4f65-9398-2e97631d5a14.png)

#### Kubeflow Notebooks
Kubeflow Notebooks provides a way to run web-based development environments inside your Kubernetes cluster by running them inside Pods.
Some key features include:
- Native support for [JupyterLab](https://github.com/jupyterlab/jupyterlab), [RStudio](https://github.com/rstudio/rstudio) and [Visual Studio Code](https://github.com/coder/code-server)
- Users can create notebook containers directly in the cluster, rather than locally on their workstations.
- Admins can provide standard notebook images for their organization with required packages pre-installed.

#### Kubeflow Pipelines
Kubeflow Pipelines is a platform for building and deploying portable, scalable machine learning (ML) workflows based on Docker containers.
The Kubeflow Pipelines platform consists of:
- A user interface (UI) for managing and tracking experiments, jobs, and runs.
- An engine for scheduling multi-step ML workflows.
- An SDK for defining and manipulating pipelines and components.
- Notebooks for interacting with the system using the SDK.


#### Katib
Katib is a Kubernetes-native project for automated machine learning (AutoML). Katib supports hyperparameter tuning, early stopping and neural architecture search (NAS).

#### Training Operators
Training of ML models in Kubeflow comes through many operators:
- TensorFlow Training (TFJob): TFJob is a Kubernetes custom resource to run [TensorFlow](https://www.tensorflow.org/) training jobs on Kubernetes. The Kubeflow implementation of TFJob is in training-operator.
- PyTorch Training (PyTorchJob): PyTorchJob is a Kubernetes custom resource to run [PyTorch](https://pytorch.org/) training jobs on Kubernetes. The Kubeflow implementation of PyTorchJob is in training-operator.

#### Elyra
[Elyra](https://github.com/elyra-ai/elyra) enables data scientists to visually create end-to-end machine learning (ML) workflows.

Elyra aims to help data scientists, machine learning engineers and AI developers through the model development life cycle complexities. Elyra integrates with JupyterLab providing a Pipeline visual editor that enables low code/no code creation of Pipelines that can be executed in a Kubeflow environment.
![image](https://user-images.githubusercontent.com/75808939/206504108-c9b4ec0b-8ff7-406c-9383-8f9082babd4b.png)

#### Istio
Kubeflow is a collection of tools, frameworks and services that are deployed together into a single Kubernetes cluster to enable end-to-end ML workflows. Most of these components or services are developed independently and help with different parts of the workflow. Developing a complete ML workflow or an ML development environment requires combining multiple services and components. Kubeflow provides the underlying infrastructure that makes it possible to put such disparate components together.

Kubeflow uses [Istio](https://istio.io/) as a uniform way to secure, connect, and monitor microservices. Specifically:
- Securing service-to-service communication in a Kubeflow deployment with strong identity-based authentication and authorization.
- A policy layer for supporting access controls and quotas.
- Automatic metrics, logs, and traces for traffic within the deployment including cluster ingress and egress.

⚠️ Currently it is not possible to deploy Kubeflow without Istio. Kubeflow needs the Istio Custom Resource Definitions (CRDs) to express the new route to access the created Notebook from the Gateway.

#### Kale
Kale enables data scientists to orchestrate end-to-end machine learning (ML) workflows.

#### KServe
[KServe](https://github.com/KServe/KServe) enables serverless inferencing on Kubernetes and provides performant, high abstraction interfaces for common machine learning (ML) frameworks like TensorFlow, XGBoost, scikit-learn, PyTorch, and ONNX to solve production model serving use cases.



#### Fairing
[Kubeflow Fairing](https://github.com/kubeflow/fairing) is a Python package that makes it easy to train and deploy ML models on Kubeflow. 

Kubeflow Fairing can also been extended to train or deploy on other platforms. Currently, Kubeflow Fairing has been extended to train on Google AI Platform.

Kubeflow Fairing packages your Jupyter notebook, Python function, or Python file as a Docker image, then deploys and runs the training job on Kubeflow or AI Platform. After your training job is complete, you can use Kubeflow Fairing to deploy your trained model as a prediction endpoint on Kubeflow.

The following are the goals of the Kubeflow Fairing project:
- Easily package ML training jobs: Enable ML practitioners to easily package their ML model training code, and their code’s dependencies, as a Docker image.
- Streamline the process of deploying a trained model: Make it easy for ML practitioners to deploy trained ML models to a hybrid cloud environment.


## Kubeflow Installation
This section is about kubeflow components installation. We will discuss every aspect in this process.

### Prerequisites
- :warning: Kubeflow can only be installed on a Kubernetes cluster.
- `Kubernetes` (up to `1.22`) with a default [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- `kustomize` (version `3.2.0`) ([download link](https://github.com/kubernetes-sigs/kustomize/releases/tag/v3.2.0))
- `kubectl`

### Kubernetes Installation
This section is needed for Kubernetes cluster setup.

- Update server
```sh
sudo apt-get update
```

- Disable swap

The idea of kubernetes is to tightly pack instances to as close to 100% utilized as possible. All deployments should be pinned with CPU/memory limits. So if the scheduler sends a pod to a machine it should never use swap at all. You don't want to swap since it'll slow things down.
Its mainly for performance.

```sh
sudo swapoff -a (This one is for disabling swap in current session)
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab (This one is disabling swap even after rebooting)
```

- Install container runtime 

Update the apt package index and install packages to allow apt to use a repository over HTTPS: 
```sh
sudo apt-get update 
sudo apt-get install \ 
    ca-certificates \ 
    curl \ 
    gnupg \ 
    lsb-release
```
  
Add Docker’s official GPG key: 
```sh
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
  
Set up the repository: 
```sh
echo \ 
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \ 
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install Docker Engine 
```sh
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
  

- Create daemon json config file 

Configure the Docker daemon, in particular to use systemd for the management of the container’s cgroups.
```sh
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
```
  

- Start and enable Services 
```sh
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
```
  

- Enable kernel modules and add configuration to sysctl 
```sh
sudo modprobe overlay
sudo modprobe br_netfilter
```
  

- Add settings to sysctl 

As a requirement for your Linux Node's iptables to correctly see bridged traffic, you should ensure net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config fo letting iptables see bridged traffic
```sh
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```
  

Reload sysctl to make changes.
```sh
sudo sysctl --system
```
  

- Update the apt package index and install packages needed to use the Kubernetes 
```sh
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```
  

- Download the Google Cloud public signing key: 
```sh
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```
  

- Add the Kubernetes apt repository: 
```sh
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```
  

- Update apt package index, install kubelet, kubeadm and kubectl 
```sh
sudo apt-get update
sudo apt-get install -y kubelet= 1.22.10-00 kubeadm= 1.22.10-00 kubectl= 1.22.10-00
```

- Then bootstrap the cluster with kubeadm. Refer to [kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/) to know more about the valid args for kubeadm init.
```sh
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --service-cidr=10.240.0.0/16
```
- Next, set up cluster access for a regular user:
```sh
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
- Next, check the cluster-info using kubectl:
```sh
kubectl cluster-info
```
- Last step is to install network plugin (CNI) on the master node:
We will be using calico CNI as a network plugin for Kubernetes as we discused earlier.
    - :warning: You need to configure custom-resources.yaml before applying it. Change Pod-cidr in the manifest file.
```sh
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml
```
### Kubernetes storage
- Kubeflow uses a default storage class to store data and create persistent volumes. We can either use a local storage like the one given by rancher or an nfs storage for external data persistency.
#### Local storage
[storageclass](https://github.com/rancher/local-path-provisioner/blob/master/deploy/local-path-storage.yaml).
```sh
kubectl create -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
```

#### NFS storage:
Network File Sharing (NFS) is a protocol that allows you to share directories and files with other Linux clients over a network. Shared directories are typically created on a file server, running the NFS server component. Users add files to them, which are then shared with other users who have access to the folder.

An NFS file share is mounted on a client machine, making it available just like folders the user created locally. NFS is particularly useful when disk space is limited and you need to exchange public data between client computers.

First we need to setup an NFS server:

```sh
sudo apt-get update
sudo apt install nfs-kernel-server
```

Next we create the mounting directory for the data storage and change it's permission so that the pod can access it and write data:
```sh
sudo mkdir /data -p
sudo chown nobody:/data
```
Next add the directory to the export file for the NFS clients:
```sh
sudo vim /etc/exports
```
Add this line to the file:
```sh
/data *(rw,no_subtree_check,no_root_squash)
```
Now enable the service and reload the /etc/exports file:
```sh
sudo systemctl enable --now nfs-server
sudo exportfs -rav
```
To verify that everything went correctly, check the mounted directories:
```sh
sudo showmount -e localhost
```
Next install the NFS client ton every node:
```sh
apt install nfs-common
```
Now we will create the manifests for the NFS storageclass on the kubernetes cluster.
You can find the yaml files in [here](https://github.com/KubeHawk/Kubeflow/tree/main/NFS)
    
```sh
kubectl create -f rbac.yaml
kubectl create -f class.yaml
kubectl create -f deployment.yaml
```

After the creation of the storageclass we need to set it up as a default storageclass:

```sh
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

#### Docker Registry
We need to setup our local registry to pull and push images faster.
First we need to add the entry in the /etc/docker/daemon.json file

```sh
"insecure-registries":["192.168.0.169:5000"]
```
The file will look like this 

```sh
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "insecure-registries":["192.168.0.169:5000"]

}
```
Next we reload the service:

```sh
systemctl daemon-reload
```
Finaly we pull the registry image and assigne a port to communicate with it. 

```sh
docker run -d -p 5000:5000 --restart=always --name registry registry
```

### Install with a single command
Get the kubeflow repo from [here](https://github.com/kubeflow/manifests#installation).
```sh
git clone https://github.com/kubeflow/manifests.git
cd manifests
```

You can install all Kubeflow official components (residing under apps) and all common services (residing under common) in [kubeflow manifests repo](https://github.com/kubeflow/manifests#installation) using the following command:

```sh
while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done
```
### Install individual components

In this section, we will install each Kubeflow official component (under apps) and each common service (under common) separately, using just kubectl and kustomize. See kubeflow [repo](https://github.com/kubeflow/manifests#installation).

## Kubeflow Authentication Architecture

![image](https://github.com/KubeHawk/Kubeflow/assets/75808939/a54a7873-b7e8-42d9-8c82-166a5e53c1a1)

## Kubeflow Workflow Architecture

![image](https://github.com/KubeHawk/Kubeflow/assets/75808939/590922e1-57f3-4cb6-bf00-d7ebc092e695)

## Spark on Kubernetes

![image](https://github.com/KubeHawk/Kubeflow/assets/75808939/6f00bf2f-e221-494b-afdd-b70ab2dea9f7)

For the deployment of spark applications on kubernetes we can use two approaches. Spark-submit or Spark-operator.

![image](https://github.com/KubeHawk/Kubeflow/assets/75808939/bf6c2ef4-f48e-4c0d-8fe2-abaf3a308e84)

In this documntation we are interested in submitting jobs from kubeflow notebooks or from outside the cluster on a local machine. In order to do that we will use the spark-submit option.

To use Spark with Kubernetes, you will need:

   - A Kubernetes cluster that has role-based access controls (RBAC) and DNS services enabled
   - Sufficient cluster resources to be able to run a Spark session (at a practical level, this means at least three nodes with two CPUs and eight gigabytes of free memory)
   - A properly configured kubectl that can be used to interface with the Kubernetes API
    Authority as a cluster administrator
   - Access to a public Docker repository or your cluster configured so that it is able to pull images from a private repository
   - Basic understanding of Apache Spark and its architecture We first need a service account for us to submit spark jobs. The driver needs to authenticate to the Kubernetes API with a service account that has permission to create pods. Kubeflow sets up a Kubernetes service account called default-editor. The namespace (created via Kubeflow) for my Notebook pods is called kubeflow-user-example-com.

We will discuss everything in the example below for better understanding.

![image](https://github.com/KubeHawk/Kubeflow/assets/75808939/8f6ce2cf-d6f2-4613-b668-f02891b7c2b8)

```sh
#!/bin/bash
PVC_NAME=spark-volume #Name of the pvc created on kubernetes that contains data volume and dependencies for the spark app and spark history server.
MOUNT_PATH=/opt/spark/work-dir #The path we use on the driver and executors pod to mount data and save logs.
/opt/spark/bin/spark-submit \
  --master k8s://https://192.168.0.111:6443 \ #Sepcifie the kubernetes api-server ip
  --deploy-mode cluster  \ #Deploy mode (Cluster or Client)
  --name sparkpi1 \ #Spark application name
  --conf spark.kubernetes.authenticate.driver.serviceAccountName=default-editor  \ #The service account to submit spark app (The service account should have the right permissions)
  --conf spark.kubernetes.namespace=kubeflow-user-example-com  \ #Same namespace as the pvc
  --conf spark.kubernetes.container.image=192.168.0.169:5000/spark-py  \ #Spark driver and executors image
  --conf spark.eventLog.enabled=true \ 
  --conf spark.eventLog.dir=/opt/spark/work-dir/logs \ #Path to store logs on the spark driver pod
  --conf spark.kubernetes.driver.volumes.persistentVolumeClaim.${PVC_NAME}.mount.path=${MOUNT_PATH} \ #Path to mount data on spark driver pod
  --conf spark.kubernetes.driver.volumes.persistentVolumeClaim.${PVC_NAME}.options.claimName=${PVC_NAME} \ #Name of pvc to use to mount data from it
  --conf spark.kubernetes.executor.volumes.persistentVolumeClaim.${PVC_NAME}.mount.path=${MOUNT_PATH} \ #Path to mount data on spark executors pod
  --conf spark.kubernetes.executor.volumes.persistentVolumeClaim.${PVC_NAME}.options.claimName=${PVC_NAME} \ #Name of pvc to use to mount data from it
  --verbose \ 
  local:////opt/spark/work-dir/khouloud.py #App to execute with full path on the spark driver pod
```

Before submitting the job we should:
    
   - Create the pvc and assinge it to the kubeflow user, and give right permissions to the logs file.
   - Create the spark image to use for spark driver and executor pods.
   - Deploy the spark history server and configure istio authorizations (RBAC).

We will start with the [persistantVolumeClaim](https://github.com/KubeHawk/Kubeflow/blob/main/Spark-history-server/pvc.yaml):

```sh
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: spark-volume
  namespace: kubeflow-user-example-com
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: nfs-client
  volumeMode: Filesystem
```
This spark pvc will use the NFS storage class we already created. Use ReadWriteMany in accessModes in order to give all executors to write and read at the same time.

For each user that wants to use the spark pvc to mount data volume we use this configuration.

![image](https://github.com/KubeHawk/Kubeflow/assets/75808939/5bea3812-1d72-4e83-8ab3-2790b4e8326b)

Next go to the NFS server under the directory of the kubeflow user and set permissions.

![image](https://github.com/KubeHawk/Kubeflow/assets/75808939/3a2233db-e194-41c1-ba02-965bf247a4d2)

```sh
sudo chmod g+rwxs -R logs #Give read and write permissions to the group for all files and directories within the "logs" directory. Additionally, it sets the setgid permission, ensuring that any new files or directories created within "logs" will inherit the group ownership.
sudo setfacl -R -m o:rwx logs #Add read, write, and execute permissions for "other" or "everyone" to all files and directories within the "logs" directory, including newly created ones.
```

The spark image used for driver and executors pod can be found [here](https://github.com/KubeHawk/Kubeflow/blob/main/spark-image/Dockerfile).

Now we are only left with the deployment of the psark history server.
You can find all the necessary yaml files in [here](https://github.com/KubeHawk/Kubeflow/tree/main/Spark-history-server)

The yaml file [History-server.yaml](https://github.com/KubeHawk/Kubeflow/blob/main/Spark-history-server/History-server.yaml) contain the deployment and service to expose the UI of spark history server.
Because isitio set an authorizationpolicy global-deny-all by default we should set manualy a rule to hndle requests towards spark history server.

The yaml file [isitio-rule.yaml](https://github.com/KubeHawk/Kubeflow/blob/main/Spark-history-server/isitio-rule.yaml) contain the rules for accessing the spark history server UI through istio authorization.


