# Infrastructure as Code - Ubuntu EC2 on AWS

<style>
.twocol ~ * { width: 50%; float: left; box-sizing: border-box; padding-left: 1rem; }
.onecol ~ * { clear: both; width: 100%; padding-left: 0; }
</style>

The following instructions will enable you to create multiple ubuntu EC2 machines within a dedicated Virtual private Cloud (VPC) in AWS. You can also provision these machines with any applications you require. Terraform is capable of basic provisioning of your machines, but for advanced application provisioning, you will be better off using a dedicated provisioning or configuration management software like Chef, Puppet, Ansible or Salt.

<div class="twocol"></div>

Here's how the system architecture looks like. For simplicity, only port 80 and 443 are shown here for http(s) connections. You can setup the VPC for allowing any kind of port access. SSH can also be limited only to your IP address for additional security, but you will have to set that up yourself.

![AWS EC2 Architecture (ubuntu)](./ubuntu.png "AWS EC2 Architecture (ubuntu)")

<div class="onecol"></div>

## Pre-requisites

Make sure you have all the pre-requisites needed to successfully run this project by clicking [here.](./Prereqs.md)

## Steps to follow  

There are three sets of steps to follow: [Configure](#cfg), [Create](#create) and [Destroy.](#destroy)

### <a name="cfg"></a>Configure

- After making sure you have met all the pre-requisites, switch to the ***iac/ubuntu*** folder in the ***iac*** project and use your favorite editor create a new ***terraform.tfvars*** file. It it already exists, edit it.
- In this file add the following information. You will need the ***public_key_path, private_key_path & key_name*** of your AWS account. NOTE: The ***public_key_path*** and ***private_key_path*** are AWS the credential key pair for SSH access. The ***key_name*** is the associated key used by AWS.

```bash
public_key_path = "~/.ssh/my_aws_public_key.pub"
private_key_path = "~/.ssh/my_aws_private_key.pem"
key_name = "my_aws_key"
```

If you are comfortable with using AWS in general you can consider changing some of the other parameters for your Ubuntu EC2 machine. See the [Advanced Configuration](#advcfg) section.

- Otherwise, go to [Create.](#create)

#### <a name="advcfg"></a>Advanced Configuration

The following steps are for those who are comfortable around AWS concepts. You can change any of the following parameters. See [Example Configuration](#advcfgex) below. NOTE: The ***region*** variable cannot be changed in this project. It needs to remain at its default value *us-east-1*.

- ***project*** is an AWS tag. The default is *demo-ubuntu*.
- Default ***ec2_type*** is *t2.small*. If the machine will be used as a server, a *t2.medium* may be a better choice. For additional AWS machine types check [here.](https://aws.amazon.com/ec2/instance-types/)
- The ***count*** variable needs to be set **only** if you want more than one EC2 machine to be created.
- ***platform*** is *linux* so nothing needs to be done here.
- For ubuntu 16.04, nothing has to be set on the ***ver*** variable. If ubuntu 14.04 or ubuntu 12.04 is needed, you can change this to *14* or *12* respectively.
- The ***db*** variable is used only for windows EC2 machines, so it can be ignored.
- The other variables can be left to their default values.

<a name="advcfgex"></a>***Example Configuration*** (include in your ***terraform.tfvars*** file)

```bash
region = "us-west-1"
project = "my-special-project"
ec2_type = "t2.medium"
count = "3"
ver = "14"
```

- Save your configuration and go to [Create.](#create)

### <a name="create"></a>Create

The following steps will show you how to create a ubuntu EC2 machine using Terraform. Make sure you have configured Terraform by following the steps in the [Configure](#cfg) section.

- At your bash prompt, run the ***terraform init*** command. The plugins will be installed and the system will be checked for proper dependencies. If there are no errors you will see output similar to the following. If there are errors click [here](./Troubleshooting.md) to troubleshoot the problem.

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform init
Initializing modules...
- module.myvpc
  Getting source "../modules/network"
- module.ubuntu
  Getting source "../modules/ec2"

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "aws" (1.23.0)...
- Downloading plugin for provider "null" (1.0.0)...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

- Now run the ***terraform apply*** command. Type ***yes*** when prompted by the system after you have reviewed the items to be created. If you don't type ***yes***, the command will be cancelled. There will be about 13-14 items created. This includes the items needed for the VPC and the EC2 machine.

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform apply
```

The result as indicated below will be output showing the details of the EC2 machine created. This example was for three EC2 ubuntu machines. You can access the machines using SSH by either specifying the IP address or the Amazon EC2 name which looks like this - ***ec2-35-168-58-160.compute-1.amazonaws.com***.

```bash
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

ubuntu_info = {
  ec2_info = map[public_dns_ip:map[ec2-35-168-58-160.compute-1.amazonaws.com:35.168.58.160
  
  ec2-34-200-250-108.compute-1.amazonaws.com:34.200.250.108 ec2-34-234-207-102.compute-1.amazonaws.com:34.234.207.102]
  
  root_volume:[[map[delete_on_termination:1 volume_size:15 volume_type:gp2 volume_id:vol-0894421517a872b2e iops:100]]
  
  [map[delete_on_termination:1 volume_size:15 iops:100 volume_id:vol-03ffa555a4eebccbe volume_type:gp2]] [map
  
  [volume_size:15 delete_on_termination:1 iops:100 volume_id:vol-0d4eb7d6ded45a5e4 volume_type:gp2]]]
  
  additional_volumes.device_names:[] additional_volumes.types:[] additional_volumes.sizes:[]]
  
  network_info = map[internet_gateway:igw-0184f4a7c178cb6e3 internet_access_cidr_block:0.0.0.0/0
  
  subnet:subnet-010f8049f1c38df87 subnet_cidr_block:10.0.1.0/24 security_group:sg-03bdd9f4f79c237a1
  
  vpc:vpc-04d46999e8a521fb3 internal_cidr_block:10.0.0.0/16]
}
```

That's it! Your AWS EC2 ubuntu machine or machines are now created and ready for use. To verify that the machine is available, SSH into the machine from a bash command prompt and verify that the machine is up and running. Try and access the machine from your browser, using both the IP address and the Amazon EC2 address. What happens?

You should get an error indicating the system is unavailable. This is because you don't have a webserver installed on the machine. Now login to the machine using SSH and install a webserver and try to access the machine again from the browser. What do you see?

You should be able to see the webserver welcome page. Play around some more and when you're done, go to the [Destroy](#destroy) section to destroy the AWS infrastructure you just created.

### <a name="destroy"></a>Destroy

Now that you are ready to destroy your newly created infrastructure, follow the steps below.

- Change to the ***iac/ubuntu*** folder at your bash prompt and type ***terraform destroy***.

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform apply
```

When prompted, type ***yes*** after making sure that the number of items being destroyed matches the number of items created. You will see the result of the command similar to what is shown below. For brevity, most of the output is not shown.

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform destroy
aws_vpc.vpc: Refreshing state... (ID: vpc-04d46999e8a521fb3)
aws_security_group.security_group: Refreshing state... (ID: sg-03bdd9f4f79c237a1)
.
.
.
.
module.myvpc.aws_vpc.vpc: Destroying... (ID: vpc-04d46999e8a521fb3)
module.myvpc.aws_vpc.vpc: Destruction complete after 1s

Destroy complete! Resources: 15 destroyed.
ubuntu@ubuntu:~/iac/ubuntu$
```

That's it! Your AWS EC2 infrastructure - VPS & EC2 machine or machines have been destroyed. To verify that the machine is no longer available, try to SSH into the machine from a bash command prompt. You should get a timeout. Try and access the machine from your browser, using both the IP address and the Amazon EC2 address. You should get an error.

## Summary

Creating an ***ubuntu*** EC2 machine was as simple as specifying a few configuration parameters in the ***terraform.tfvars*** file and running a couple of Terraform commands. Terraform does the hard lifting and creates the EC2 machines. Destroying the infrastructure created by Terraform is also quite easy. Now that you see the power of Terraform, try some of the other projects (e.g. [iacec2](./Iacec2.md)). To understand how Terraform does its magic read up on basic Terraform concepts [here](./Terraform.md) or go to the [source](http://www.terraform.io) itself and learn more.  
