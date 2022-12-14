#!/bin/bash
################################################
##   Setup Script for Kubernetes environment  ##
##                 Omar Achour                ##
##                                            ##
################################################

# Perform all these commands on every node
# Update servers
sudo apt-get update

# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install container runtime
# Install dependencies
sudo apt-get update 
sudo apt-get install \ 
    ca-certificates \ 
    curl \ 
    gnupg \ 
    lsb-release 

# Add Docker’s official GPG key
sudo mkdir -p /etc/apt/keyrings 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 

# Set up the repository
echo \ 
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \ 
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 

# Install Docker Engine
sudo apt-get update 
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin 

# Create daemon json config file 
# Configure the Docker daemon, in particular to use systemd for the management of the container’s cgroups.

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

# Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker 
sudo systemctl enable docker 

# Enable kernel modules and add configuration to sysctl 
sudo modprobe overlay 
sudo modprobe br_netfilter

# Add settings to sysctl 
# Letting iptables see bridged traffic
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF 
net.bridge.bridge-nf-call-ip6tables = 1 
net.bridge.bridge-nf-call-iptables = 1 
net.ipv4.ip_forward = 1 
EOF 

# Reload sysctl to make changes
sudo sysctl --system 

# Update the apt package index and install packages needed to use the Kubernetes
sudo apt-get update 
sudo apt-get install -y apt-transport-https ca-certificates curl

# Download the Google Cloud public signing key
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg 

# Add the Kubernetes apt repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list 

# Update apt package index, install kubelet, kubeadm and kubectl
sudo apt-get update 
sudo apt-get install -y kubelet=1.22.10-00 kubeadm= 1.22.10-00 kubectl= 1.22.10-00 



