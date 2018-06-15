# This is a module file which describes an aws ec2 instance
# It can create multiple Windows or Linux EC2 machines in AWS
# It assumes that the provider is specified in the calling parent
# Multiple volumes can be attached to the created EC2

provider "null" { version = "~> 1.0"}
variable "count" {
    description = "Count of instances"
    default = 1
}
variable "project" {
    description = "Name of the project. This will be added to the Project tag"
    default = "demo"
}
variable "machine_name" {
    description = "User friendly name of the machine."
    default = "demo-ec2"
}
variable "instance_type" {
    description = "AWS EC2 instance type"
}
variable "private_key_path" {
    description = <<DESCRIPTION
Path to the private key for administrative SSH login from your remote machine.
In Linux systems this typically is ~/.ssh/id_rsa.pem
In Windows systems you could either use WSL (Ubuntu bash under windows) or git-bash or equivalent.
DESCRIPTION
}
variable "public_key_path" {
	description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect. Example: ~/.ssh/terraform.pub
DESCRIPTION
}
variable "key_name" {
    description = "Name of the AWS key to be used for access."
    description = <<DESCRIPTION
Name of the AWS key to be used for access. This is usually created when a user is created 
in the AWS account.
NOTE: This needs to be an existing key and preferably only to be used for this project
to ensure security. The private pem file for this key must be kept in a safe location. 
DESCRIPTION
}
variable "region" {
	description = "AWS region to launch servers."
	default     = "us-east-1"
}
variable "sg_ids" {
    type = "list"
    description = "List of security group ids"
}
variable "subnet_id" {
    description = "Subnet id of the VPC into which the AMI is launched"
}
variable "platform" {
    description = "This is the variable that determines whether Linux or Windows EC2 is created."
}
variable "ver" {
    description = <<DESCRIPTION
Server OS version info. 
For Linux since we are only using ubuntu variants, the valid versions are
12,14,16 - corresponding to ubuntu 12.04, 14.04 and 16.04.
The default setting is 16 (ubuntu 16.04)
NOTE: That 12.04 is no longer supported by the ubuntu org, so it is recommended that
ubuntu 16.04 is used. 
For Windows, the version numbers are 2012R2 and 2016 corresponding to
Windows 2012 R2 Server and Windows 2016 Server.  
DESCRIPTION
}
variable "db" {
    description = "Is MS SQL Server Standard or Enterprise installed. Valid values are [ssql|esql|none]."
    default = "none"
}
variable "username" {
    description = <<DESCRIPTION
User name for administrative SSH login to the EC2 instance.
This username is used by terraform when provisioning the EC2 instance using the provisioners.
For Linux, this normally is whatever the default user account on the EC2 is
for example: on ubuntu it is "ubuntu" on Amazon linux it is ec2-user etc. 
For Windows, this normally is the "Administrator". NOTE: Currently this version of terraform config
has no provisioners configured.  
DESCRIPTION
}
variable "root_volume" {
    description = "Root volume of the EC2 instance"
    default = { type = "gp2", size = 8, delete_on_termination = "true" }
}
variable "additional_volumes" {
    type = "list"
    description = "Volumes (in addition to root volume) attached to the EC2 instance."
}
variable "files_to_copy" {
    description = "Map of files to be copied to EC2 instance"
    default = [{ source = "", destination = "" }]
}
variable "remote_commands" {
    type = "list"
    description = "List of commands to be run sequentially on the EC2 instance."
}
variable "amis" {
    description = <<DESCRIPTION
AMIs for both Linux and Windows based on region. NOTE That the keys in this map
are coded differently between Windows and Linux.
For Windows the coding of the key is <ver>-<db>-<region>. 
The db portion is to accomodate SQL server - Enterprise or Standard.
Its value will be esql for Enterprise SQL Server, ssql for Standard SQL Server and none for a
machine which doesn't have SQL server. If you want to install your own version of SQL Server,
you can use the none option of the database and provision the machine separately.     
For Linux the coding of the key is <ver>-<region>. You can install any DB you want through the
provisioners. 
NOTE: The AMIs in this list are all picked with the above attributes.
DESCRIPTION
    default = { 
        "12-us-east-1" = "ami-a04529b6"
        "14-us-east-1" = "ami-c29e1cb8"
        "16-us-east-1" = "ami-aa2ea6d0"
        "2012R2-sqle-us-east-1" = "ami-75493d0f"
        "2012R2-ssql-us-east-1" = "ami-eeb5c194"
        "2012R2-esql-us-east-1" = "ami-ab4733d1"
        "2012-none-us-east-1" = "ami-455f2b3f"
        "2012R2-none-us-east-1" = "ami-e443379e"
        "2016-esql-us-east-1" = "ami-63acd819"
        "2016-ssql-us-east-1" = "ami-b9a3d7c3"
        "2016-none-us-east-1" = "ami-4096e23a"
    }
}
locals {
    type = "${var.platform == "windows" ? "winrm":"ssh"}"
    ami_key = "${var.platform == "windows" ? "${var.ver}-${var.db}-${var.region}" : "${var.ver}-${var.region}" }"
}
resource "aws_instance" "ec2" {
    count = "${var.count}"
    instance_type = "${var.instance_type}"
    ami = "${lookup(var.amis,local.ami_key)}"
    vpc_security_group_ids = ["${var.sg_ids}"] 
    subnet_id = "${var.subnet_id}"
    key_name = "${var.key_name}" # If this is not present we can't ssh into the system. 
    root_block_device {
        volume_type = "${lookup(var.root_volume,"type")}"
        volume_size = "${lookup(var.root_volume,"size")}"
        delete_on_termination = "${lookup(var.root_volume,"delete_on_termination")}"
    }
    tags {
        Name = "${var.machine_name}-${count.index}"
        Project = "${var.project}"
        Platform = "${title(var.platform)}"
    }
}

locals {
    _provision_ec2 = "${var.platform == "windows" ? 0 : 1}"    
    provision_ec2 = "${var.count > 0 ? (local._provision_ec2 * var.count) : 0 }"  # No provisioning if resource count is zero. 
}
# Used for provisioning of commands. Currently on windows systems we need password.  
resource "null_resource" "provisioning" {
    depends_on = [ "aws_instance.ec2", "null_resource.file_copy" ]
    count = "${local.provision_ec2}"    # This will be > 0 if Linux & 0 if Windows
    triggers {
        provisioning_ec2_id = "${element(aws_instance.ec2.*.id,count.index)}"
        filecopy = "${join(",",null_resource.file_copy.*.id)}" 
    }
    connection {
        host = "${element(aws_instance.ec2.*.public_ip,count.index)}"
        type = "${local.type}"
        user = "${var.username}" 
        private_key = "${file(var.private_key_path)}" 
    }
    provisioner "remote-exec" {
        inline = "${var.remote_commands}"
        //on_failure = "continue" 
    }
}

locals {
    _filecopy = "${lookup(var.files_to_copy[0],"source") == "" ? 0 : 1 }"
    _filecopy_count = "${local._filecopy == 1 ? length(var.files_to_copy) : 0 }"
    filecopy_count = "${var.count > 0 ? (local._filecopy_count * var.count) : 0 }"    # No file copy if resource count is zero.
    filecopy_count_divisor = "${local._filecopy_count}"
}
# Used for copying files to the EC2. Currently we use this on Linux only.  
resource "null_resource" "file_copy" {
    depends_on = [ "aws_instance.ec2" ]
    count = "${local.filecopy_count}"    # This will be > 0 if we need to copy files to the remote resource
    triggers {
        provisioning_ec2_id = "${element(aws_instance.ec2.*.id,count.index)}"
    }
    connection {
        host = "${element(aws_instance.ec2.*.public_ip,count.index)}"
        type = "${local.type}"
        user = "${var.username}" 
        private_key = "${file(var.private_key_path)}" 
    }
    provisioner "file" {
        source = "${lookup(var.files_to_copy[(count.index % local.filecopy_count_divisor)],"source")}"
        destination = "${lookup(var.files_to_copy[(count.index % local.filecopy_count_divisor)],"destination")}"
    }
}

locals {
    _additional_volume_count = "${length(var.additional_volumes)}" 
    additional_volume_count = "${var.count > 0 ? (local._additional_volume_count * var.count) : 0 }" # No additional volumes if count is zero
    additional_volume_count_divisor = "${local._additional_volume_count}"
}
# Used for creating additional volumes on the EC2. Data is supplied in the additional_volumes array
resource "aws_ebs_volume" "vebs" {
    count = "${local.additional_volume_count}"
    availability_zone = "${element(aws_instance.ec2.*.availability_zone,count.index)}"
    type = "${lookup(var.additional_volumes[(count.index % local.additional_volume_count_divisor)],"type")}"
    size = "${lookup(var.additional_volumes[(count.index % local.additional_volume_count_divisor)],"size")}"
}

# Attaches the created additional volumes on the EC2. Same data supplied in the additional_volumes array is used
resource "aws_volume_attachment" "vattach" {
    count = "${local.additional_volume_count}"
    device_name = "${lookup(var.additional_volumes[(count.index % local.additional_volume_count_divisor)],"device_name")}"
    instance_id = "${element(aws_instance.ec2.*.id,count.index)}"
    volume_id = "${element(aws_ebs_volume.vebs.*.id,count.index)}"
}

output "ec2_info" {
    description = "EC2 instance information."
    value = {
        public_dns_ip = "${zipmap(aws_instance.ec2.*.public_dns,aws_instance.ec2.*.public_ip)}"
        root_volume = "${aws_instance.ec2.*.root_block_device}"
        additional_volumes.device_names = "[${join(",",aws_volume_attachment.vattach.*.device_name)}]"
        additional_volumes.types = "[${join(",",aws_ebs_volume.vebs.*.type)}]"  
        additional_volumes.sizes = "[${join(",",aws_ebs_volume.vebs.*.size)}]" 
    }
}

output "ec2_ip" {
    description = "EC2 instance id."
    value = "${aws_instance.ec2.*.public_ip}"
}
