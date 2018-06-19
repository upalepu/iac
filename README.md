# Infrastructure as Code

Having the ability to create your own virtual data center in just a couple of minutes is a very powerful feeling. It can be helpful for creating demo environments, testing and validation and even production environments if designed well. More importantly, being able to scale up/down your infrastructure automatically and take it all down is very cost efficient, convenient and powerful. This project is an attempt at creating a few sample environments in AWS using Terraform and bash scripting. For a brief synopsis on the folder structure and how to use Terraform, click [here.](./docs/Terraform.md)

The table below lists the various cloud infrastructure artifacts which can be created using the resources in this folder. Instructions for using each type of artifact are also provided.

Name|Cloud Platform|Artifact(s)|Status|Description
---|---|---|---|---
[ubuntu](./docs/Ubuntu.md)|AWS|EC2|Stable|Ubuntu EC2 machine in isolated VPC with SSH access
[iacec2](./docs/Iacec2.md)|AWS|EC2, AWS Command Line, Terraform, iac project|Testing|Ubuntu EC2 in isolated VPC for developing/testing iac/terraform/kubernetes
[kubernetes](./docs/Kubernetes.md)|AWS|AWS Environment, Kubernetes Cluster, kops, kubectl|Testing|Sets up AWS and a Kubernetes cluster on (iacec2) for development/testing

[comment]: # (Upcoming items)
[comment]: # (windows|AWS|EC2|Not Done|Windows Server Basic|)

To try out creating your own infrastructure using code, either clone this project using git or download it to your local machine and try it out. For more advanced projects like ***kubernetes***, first create an AWS EC2 machine using the ***iacec2*** project and try your projects there so you can have a clean and disposable environment.

```bash
ubuntu@ubuntu:~$git clone https://github.com/upalepu/iac.git
```

---

## <a name="ubuntu"></a>*Ubuntu EC2s on AWS*

For details on creating Ubuntu machines on AWS click [here.](./docs/Ubuntu.md)

---

## <a name="tfo"></a>*Folder structure and Terraform usage overview*

For a brief overview ofthe folder structure in this project and Terrafrom click [here.](./docs/Terraform.md)

---

## <a name="iacec2"></a>*Develop/Test IAC with Terraform/Kubernetes on AWS EC2 (iacec2)*

For details on creating a Dev/Test environment with Terraform, Kubernetes and AWS command line on an AWS EC2 machine click [here.](./docs/Iacec2.md)

---

## <a name="kubernetes"></a>*Kubernetes Cluster on AWS*

For details on setting up and using a Kubernetes Cluster on AWS using the (iacec2) machine click [here.](./docs/Kubernetes.md)

---

## <a name="awsclii"></a>*Quick way to install AWS CLI*

For details on a quick way to install the AWS CLI click [here.](./docs/Awscliquickinstall.md)

---

## *Troubleshooting*

For troubleshooting details click [here.](./docs/Troubleshooting.md)