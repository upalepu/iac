# Infrastructure as Code
Having the ability to create your own virtual data center in just a couple of minutes is a very powerful feeling. It can be helpful for creating demo environments, testing and validation and even production environments if designed well. More importantly, being able to scale up/down your infrastructure automatically and take it all down is very cost efficient, convenient and powerful. This project is an attempt at creating a few sample environments in AWS using Terraform and bash scripting. For a brief synopsis on the folder structure and how to use Terraform, click [here.](#tfo)     

The table below lists the various cloud infrastructure artifacts which can be created using the resources in this folder. Instructions for using each type of artifact are also provided. 

Name|Cloud Platform|Artifact|Status|Description
---|---|---|---|---
[ubuntu](#ubuntu)|AWS|EC2|Stable|Ubuntu EC2 machine in isolated VPC with SSH access 
kubernetes|AWS|AWS Setup|Testing|Sets up AWS for running kubernetes cluster 
iacec2|AWS|EC2|Testing|Ubuntu EC2 in isolated VPC for developing/testing iac/terraform/kubernetes 

[comment]: # (Upcoming items)
[comment]: # (windows|AWS|EC2|Not Done|Windows Server Basic|)

To try out creating your own infrastructure using code, either clone this project using git or download it to your local machine and try it out.

```bash
ubuntu@ubuntu:~$git clone https://github.com/upalepu/iac.git
```

---
## *General pre-requisites* 

1) You will need an AWS Account. If you don't have an account, sign up for free [here.](https://aws.amazon.com/free/)   
2) You will also need your AWS ***Access Key Id*** and ***Secret Access Key***. Check out details on how to get these [here.](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html)
If you don't have these or lost them you can recreate these. Check out details [here.](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)    
3) You will need the AWS Commandline Interface (CLI) installed on your local machine. For a quick way to install the AWS CLI on your local machine, follow the instructions [here.](#awsclii)       
4) You will need ***terraform*** installed on your local machine. Check out details [here.](./docs/Terraforminstall.md)

---

## <a name="ubuntu"></a>*To create Ubuntu Machines on AWS* 
For details on creating Ubuntu machines on AWS click [here.](./docs/Ubuntu.md) 

---
## <a name="tfo"></a>*Folder structure and Terraform usage overview*
For a brief overview ofthe folder structure in this project and Terrafrom click [here.](./docs/Terraform.md)

---
## <a name="awsclii"></a>*Quick way to install AWS CLI*
For details on a quick way to install the AWS CLI click [here.](./docs/Awscliquickinstall.md)

---
## *Troubleshooting*
For troubleshooting details click [here.](./docs/Troubleshooting.md)