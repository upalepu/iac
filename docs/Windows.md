# Infrastructure as Code - Windows EC2 on AWS

The following instructions will enable you to create multiple Windows EC2 machines within a dedicated Virtual private Cloud (VPC) in AWS. You can also provision these machines with any applications you require. Terraform is capable of basic provisioning of your machines, but for advanced application provisioning, you will be better off using a dedicated provisioning or configuration management software like Octopus, Chef, Puppet, Ansible or Salt.

<div class="twocol"></div>

Here's how the system architecture looks like. For simplicity, only port 80 and 443 are shown here for http(s) connections. You can setup the VPC for allowing any kind of port access. SSH can also be limited only to your IP address for additional security, but you will have to set that up yourself.

![AWS EC2 Architecture (windows)](./windows.png "AWS EC2 Architecture (windows)")

<div class="onecol"></div>

## Pre-requisites

Make sure you have all the pre-requisites needed to successfully run this project by clicking [here.](./Prereqs.md)

## Steps to follow  

There are three sets of steps to follow: [Configure](#cfg), [Create](#create) and [Destroy.](#destroy)

### <a name="cfg"></a>Configure

- After making sure you have met all the pre-requisites, switch to the ***iac/winec2*** folder in the ***iac*** project and use your favorite editor create a new ***terraform.tfvars*** file. It it already exists, edit it.
- In this file add the following information. You will need the ***key_name*** of your AWS account and a password ***pwd*** for the Windows Administrator login. NOTE:The ***key_name*** is the associated key used by AWS for your account. The password should conform to Windows password requirements. Click [here](https://docs.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/password-must-meet-complexity-requirements) to see what these requirements are.

```bash
key_name = "my_aws_key"
pwd = "Ph9gt7-nk45!4tM5Np84"
```

If you are comfortable with using AWS in general you can consider changing some of the other parameters for your Windows EC2 machine. See the [Advanced Configuration](#advcfg) section.

- Otherwise, go to [Create.](#create)

#### <a name="advcfg"></a>Advanced Configuration

The following steps are for those who are comfortable around AWS concepts. You can change any of the following parameters. See [Example Configuration](#advcfgex) below.

- ***project*** is an AWS tag. The default is *demo-winec2*.
- Default ***ec2_type*** is *t2.small*. If the machine will be used as a server, a *t2.medium* may be a better choice. For additional AWS machine types check [here.](https://aws.amazon.com/ec2/instance-types/)
- The ***count*** variable needs to be set **only** if you want more than one EC2 machine to be created.
- For Windows 2016 Server, nothing has to be set on the ***ver*** variable. Other valid values are *2012* & *2012R2*.
- The ***db*** variable defaults to *none*, but valid values are *ssql* (Microsoft Standard SQL Server) and *esql* (Microsoft Enterprise SQL Server). When specifying these servers, make sure the root volume size is specified appropriately to accomodate the database needs.
- The other variables can be left to their default values.

<a name="advcfgex"></a>***Example Configuration*** (include in your ***terraform.tfvars*** file)

```bash
region = "us-west-1"
project = "my-special-project"
ec2_type = "t2.medium"
count = "3"
ver = "2012R2"
db = "ssql"
```

- Save your configuration and go to [Create.](#create)

### <a name="create"></a>Create

The following steps will show you how to create a Windows EC2 machine using Terraform. Make sure you have configured Terraform by following the steps in the [Configure](#cfg) section.

- At your bash (command) prompt, run the ***terraform init*** command. The plugins will be installed and the system will be checked for proper dependencies. If there are no errors you will see output similar to the following. If there are errors click [here](./Troubleshooting.md) to troubleshoot the problem.

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform init
Initializing modules...
- module.myvpc
  Getting source "../modules/network"
- module.winec2
  Getting source "../modules/wec2"

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

- Now run the ***terraform apply*** command. Type ***yes*** when prompted by the system after you have reviewed the items to be created. If you don't type ***yes***, the command will be cancelled. There will be several items created. This includes the items needed for the VPC and the EC2 machine.

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform apply
```

The result as indicated below will be output showing the details of the EC2 machine created. This example was for three EC2 Windows machines. You can access the machines using Windows RDP by either specifying the IP address or the Amazon EC2 name which looks like this - ***ec2-35-168-58-160.compute-1.amazonaws.com***.

```bash
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:

ubuntu_info = {
  ec2_info = map[public_dns_ip:map[ec2-35-168-58-160.compute-1.amazonaws.com:35.168.58.160
  
  ec2-34-200-250-108.compute-1.amazonaws.com:34.200.250.108 ec2-34-234-207-102.compute-1.amazonaws.com:34.234.207.102]
  
  root_volume:[[map[delete_on_termination:1 volume_size:15 volume_type:gp2 volume_id:vol-0894421517a872b2e iops:100]]
  
  [map[delete_on_termination:1 volume_size:15 iops:100 volume_id:vol-03ffa555a4eebccbe volume_type:gp2]] [map
  
  [volume_size:40 delete_on_termination:1 iops:100 volume_id:vol-0d4eb7d6ded45a5e4 volume_type:gp2]]]
  
  additional_volumes.device_names:[] additional_volumes.types:[] additional_volumes.sizes:[]]
  
  network_info = map[internet_gateway:igw-0184f4a7c178cb6e3 internet_access_cidr_block:0.0.0.0/0
  
  subnet:subnet-010f8049f1c38df87 subnet_cidr_block:10.0.1.0/24 security_group:sg-03bdd9f4f79c237a1
  
  vpc:vpc-04d46999e8a521fb3 internal_cidr_block:10.0.0.0/16]
}
```

That's it! Your AWS EC2 Windows machine or machines are now created and ready for use. To verify that the machine is available, RDP into the machine from a bash (or command) prompt and verify that the machine is up and running. NOTE: The username is the same as in the ***winec2-vars.tf*** file. The default value is *Administrator*. The password is the same one specified in the ***pwd*** field of ***terraform.tfvars*** file. Try and access the machine from your browser, using both the IP address and the Amazon EC2 address. What happens?

You should get an error indicating the system is unavailable. This is because you don't have a webserver installed on the machine. You can use the machine via RDP for any experimentation. Play around and experiment. When you're done, go to the [Destroy](#destroy) section to destroy the AWS infrastructure you just created.

### <a name="destroy"></a>Destroy

Now that you are ready to destroy your newly created infrastructure, follow the steps below.

- Change to the ***iac/winec2*** folder at your bash (command) prompt and type ***terraform destroy***.

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform destroy
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

That's it! Your AWS EC2 infrastructure - VPC & EC2 machine or machines have been destroyed. To verify that the machine is no longer available, try to RDP into the machine. You should get an error.

## Summary

Creating a ***winec2*** EC2 machine was as simple as specifying a few configuration parameters in the ***terraform.tfvars*** file and running a couple of Terraform commands. Terraform does the hard lifting and creates the EC2 machines. Destroying the infrastructure created by Terraform is also quite easy. Now that you see the power of Terraform, try some of the other projects (e.g. [iacec2](./Iacec2.md)). To understand how Terraform does its magic read up on basic Terraform concepts [here](./Terraform.md) or go to the [source](http://www.terraform.io) itself and learn more.  

<style>
.twocol ~ * { width: 50%; float: left; box-sizing: border-box; padding-left: 1rem; }
.onecol ~ * { clear: both; width: 100%; padding-left: 0; }
</style>
