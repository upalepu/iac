# Infrastructure as Code - To create Ubuntu machines on AWS

The following instructions will enable you to create multiple ubuntu EC2 machines within a dedicated Virtual private Cloud (VPC) in AWS. You can also provision these machines with any applications you require. Terraform is capable of basic provisioning of your machines, but for advanced application provisioning, you will be better off using a dedicated provisioning or configuration management software like Chef, Puppet, Ansible or Salt.

## Specific pre-requisites

1) Your favorite IDE or code editor (e.g. vscode, notepad++, vi etc.)

## Steps to follow  

- Switch to the ***ubuntu*** sub-folder in the ***iac*** project and open the ***ubuntu-vars.tf*** which contains all the configurable variables
- Set the appropriate variables. At a minimum, the following variables need to be updated: ***public_key_path, private_key_path & key_name***. Provide the required information for each of these variables in the ***default*** key as shown below.

NOTE: The ***public_key_path*** and ***private_key_path*** are AWS the credential key pair for SSH access. You need to provide the path to these files in these two configration variables.

```bash
variable "public_key_path" {
    description = <<DESCRIPTION
Authentication for SSH Access to AWS Linux EC2 machines.
Path to the SSH public key to be used for authentication.
This is the key file that AWS creates and includes in every EC2 machine.
Linux Example: "~/.ssh/my_aws_public_key.pub"
NOTE: This only is required for Linux machines.
DESCRIPTION
    default = "<your public key path>"
}
variable "private_key_path" {
    description = <<DESCRIPTION
Private key file which AWS provides for your specific user account.
This file path should be supplied so Terraform can login to the AWS EC2 machine
and do remote administration tasks.
Linux Example: "~/.ssh/my_aws_private_key.pem"
DESCRIPTION
    default = "<your private key path>"
}
variable "key_name" {
    description = <<DESCRIPTION
This is the name of the Key Pair in your AWS account that you are using.
You will be able to find this in the AWS console under "Key Pairs".
DESCRIPTION
    default = "<your AWS key name>"
}  
```

- The default AWS ***region*** is set to *us-east-1*. If using the EC2 machine for testing and demo, this can be left unchanged.
- ***project*** needs to **only** be set if the default value is not acceptable.
- Default ***ec2_type*** is *t2.small*. If the machine will be used as a server, a *t2.medium* may be a better choice. For additional AWS machine types check [here.](https://aws.amazon.com/ec2/instance-types/)
- The ***count*** variable needs to be set **only** if more than one EC2 machine needs to be created.
- ***platform*** is *linux* so nothing to be done here.
- For ubuntu 16.04, nothing has to be set on the ***ver*** variable. If ubuntu 14.04 or ubuntu 12.04 is needed, you can change this to "14" or "12" respectively.
- The ***db*** variable is used only for windows EC2 machines, so it can be left alone.
- The other variables can be left to their default values.
- Once all the variables have been set, run the ***terraform init*** command. The plugins will be installed and the system will be chacked for proper dependencies. If there are no errors you can go to the next step.  

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform init
```

- Now run the ***terraform apply*** command. Type "yes" when prompted by the system after you have reviewed the items to be created. If one ubuntu machine is created, there will be about 14 items created. Note that this includes all the items in the VPC.

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform apply
```

- That's it! Your AWS EC2 ubuntu machine is now created and ready for use. To verify that the machine is available, SSH into the machine from a bash command prompt and verify that the machine is up and running.

## Summary

Creating an ubuntu EC2 machine was as simple as specifying a few configuration parameters in the ubuntu-vars.tf file and running terraform. Terraform does the hard lifting and creates the EC2 machines.  
