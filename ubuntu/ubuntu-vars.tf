# This file contains variables which are referenced and used by the various terraform
# configuration files in this project.
# Most commonly needed variable are included here. 
# Changing the value in the variable will enable a different configuration to be created.
# See individual variable descriptions for information on how to change variables. 
variable "public_key_path" {
	description = <<DESCRIPTION
Authentication for SSH Access to AWS Linux EC2 machines.
Path to the SSH public key to be used for authentication. 
This is the key file that AWS creates and includes in every EC2 machine.
Linux Example: "~/.ssh/my_aws_public_key.pub"
NOTE: This only is required for Linux machines.
DESCRIPTION
	default = ""
}
variable "private_key_path" {
  	description = <<DESCRIPTION
Private key file which AWS provides for your specific user account. 
This file path should be supplied so Terraform can login to the AWS 
EC2 machine and do remote administration tasks.
Linux Example: "~/.ssh/my_aws_private_key.pem"
DESCRIPTION
	default = ""
}
variable "key_name" {
  	description = <<DESCRIPTION
This is the name of the Key Pair in your AWS account that you are using.
You will be able to find this in the AWS console under "Key Pairs". 
DESCRIPTION
	default = ""
}
variable "region" {
  	description = "This is the AWS region where you want to create your Virtual Private Cloud and the virtual EC2 machines." 
	default     = "us-east-1"
}
variable "project" {
    description = <<DESCRIPTION
This variable is used to tag all AWS resources in case you need to search for them using the AWS Console or CLI
DESCRIPTION
    default = "demo-ubuntu"
}
variable "ec2_type" {
    description = <<DESCRIPTION
This variable is used to specify the AWS type (e.g. t2.small, m2.large etc.) and will be used to create the EC2.
For a detaled description of AWS EC2 types and uses, see the AWS link specified here https://aws.amazon.com/ec2/instance-types/ 
DESCRIPTION
    default = "t2.small"
}

variable "count" {
    description = <<DESCRIPTION
This variable is used to determine number of EC2 machines to be created.  
DESCRIPTION
    default = "1"
}

variable "platform" {
    description = <<DESCRIPTION
This variable specified whether the platform is windows or linux. It's a custom variable which is used internally by the
ec2 module. Valid values are "windows" & "linux". Case is important. 
DESCRIPTION
    default = "linux"
}

variable "ver" {
    description = <<DESCRIPTION
This variable is a custom variable used by th ec2 module. It is used to determine which AMI to use. 
Valid values for this variable are "12", "14" & "16" for linux. Each of these correspond to the latest 
ubuntu 12.xx, 14.xx & 16.04 versions. 
DESCRIPTION
    default = "16"
}
variable "db" {
    description = <<DESCRIPTION
This variable is a custom variable used by th ec2 module. It is used in windows ec2 machines only to determine whether
to install SQL server or not. Valid values are "none", "esql" & "ssql". 
esql is for Enterprise SQL Server and ssql is for Standard SQL Server.
none - creates the machines with no SQL Server.
DESCRIPTION
    default = "none"
}
variable "username" {
    description = <<DESCRIPTION
This variable is the user account on the ec2machine to login to SSH (linux) or WINRM (windows).
NOTE: Since the default platform is linux, the default username is set to ubuntu  
DESCRIPTION
    default = "ubuntu"
}
variable "rootvol" {
    type = "map"
    description = <<DESCRIPTION
The following map provides the root volume data for the EC2
Valid type values are "gp2", "io1", "st1", "sc1" - but "gp2" is recommended in general as it has the best ROI.
Valid size values are - 8GB - 16TB. It is important to have a size which will accomodate the workload.
DESCRIPTION
    default = { type = "gp2", size = "15", delete_on_termination = "true" }
}

variable "additional_volumes" {
    type = "list"
    description = <<DESCRIPTION
The following list of volume maps provide the data for the additional disks of the EC2 if needed.
Valid device_name values are "/dev/xvd[e-z]"
Valid type values are "gp2", "io1", "st1", "sc1" - but "gp2" is recommended in general as it has the best ROI.
Valid size values are - 8GB - 16TB. It is important to have a size which will accomodate the workload. 
DESCRIPTION
    default = [
#       { device_name = "/dev/xvde", type = "gp2", size = 8 },
#   	{ device_name = "/dev/xvdf", type = "gp2", size = 8 },
    ]
}
variable "files_to_copy" {
    type = "list"
    description = <<DESCRIPTION
The following is a list of maps for files to copy to the EC2
DESCRIPTION
    default = [
#        { source = "", destination = "" }, 
    ]
}
variable "remote_commands" {
    type = "list"
    description = <<DESCRIPTION
The following list of commands will be executed in the EC2 machine after it is created. 
DESCRIPTION
    default = [
        "sudo apt-get -y update",
    ]
}

