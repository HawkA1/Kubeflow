# Kubeflow Documentation

## Table of Contents

<!-- toc -->

- [Overview](#overview)
- [Cluster environment](#cluster-environment)
- [Kubeflow components](#kubeflow-components)
- [Kubeflow Installation](#kubeflow-installation)
  * [Prerequisites](#prerequisites)
  * [Kubernetes Installation](#kubernetes-installation)
  * [Install with a single command](#install-with-a-single-command)
  * [Install individual components](#install-individual-components)

<!-- tocstop -->

## Overview
This documentation is for anyone trying to build a [Kubernetes](https://kubernetes.io/docs/home/) based environment fo machine learning using [Kubeflow](https://www.kubeflow.org/docs/started/introduction/).

The Kubeflow project is dedicated to making deployments of machine learning (ML) workflows on Kubernetes simple, portable and scalable. Kubeflow is a platform for data scientists who want to build and experiment with ML pipelines. Kubeflow is also for ML engineers and operational teams who want to deploy ML systems to various environments for development, testing, and production-level serving.

## Cluster environment
For this project environment we used:
- 3 Ubuntu 22.04 Servers. 
- 3 VMs with Intel(R) Core (TM) i7-4790 CPU @ 3.60GHz and 16GB RAM DDR3.
- `Master node IP:` 192.168.1.74
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
![image](https://user-images.githubusercontent.com/75808939/206500339-c2651a3e-93c6-4fcf-a45c-eea5a6ceca54.png)


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

### Prerequisites

### Kubernetes Installation

### Install with a single command

### Install individual components

