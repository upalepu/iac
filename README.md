# Infrastructure as Code

Having the ability to create your own virtual data center in just a couple of minutes is a very powerful feeling. It can be helpful for creating demo environments, testing and validation and even production environments if designed well. More importantly, being able to scale up/down your infrastructure automatically and take it all down is very cost efficient, convenient and powerful. This project is an attempt at creating a few sample environments in AWS using Terraform and bash scripting. For a brief synopsis on the folder structure and how to use Terraform, click [here.](./docs/Terraform.md)

The table below lists the various cloud infrastructure artifacts which can be created using the resources in this folder. Instructions for using each type of artifact are also provided.

Name|Cloud Platform|Artifact(s)|Status|Description
---|---|---|---|---
[ubuntu](./docs/Ubuntu.md)|AWS|EC2|Stable|Ubuntu EC2 machine in isolated VPC with SSH access
[winec2](./docs/Windows.md)|AWS|EC2, SQL Server (if specified)|Stable|Windows EC2 machine in isolated VPC with RDP access

To try out creating your own infrastructure using code, either clone this project using git or download it to your local machine and try it out.

```bash
ubuntu@ubuntu:~$git clone https://github.com/upalepu/iac.git
```

---

## <a name="ubuntu"></a>*Ubuntu EC2s on AWS*

For details on creating Ubuntu machines on AWS click [here.](./docs/Ubuntu.md)

---

## <a name="winec2"></a>*Windows EC2s on AWS*

For details on creating Windows machines on AWS click [here.](./docs/Windows.md)

---

## <a name="tfo"></a>*Folder structure and Terraform usage overview*

For a brief overview ofthe folder structure in this project and Terrafrom click [here.](./docs/Terraform.md)

---

## <a name="awsclii"></a>*Quick way to install AWS CLI*

For details on a quick way to install the AWS CLI click [here.](./docs/Awscliquickinstall.md)

---

## *Troubleshooting*

For troubleshooting details click [here.](./docs/Troubleshooting.md)