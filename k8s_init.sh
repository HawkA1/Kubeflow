#!/bin/bash
################################################
##   Setup Script for Kubernetes environment  ##
##                 Omar Achour                ##
##                                            ##
################################################

# This file is for bootstraping a kubernetes cluster with kubeadm

# First you need to choose the pod-network-cidr and service-cidr carefully! There should be no overlaping with your existing network.
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --service-cidr=10.240.0.0/16

# Next, set up cluster access for a regular user
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# install network plugin (CNI) on the master node. You need to configure custom-resources.yaml with your pod-network-cidr before creating the pod if you changed it in the previous command.  
kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml 
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml
