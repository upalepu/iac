# This is a module file which describes an aws ec2 instance
# It can create multiple Linux EC2 machines in AWS
# It assumes that the provider is specified in the calling parent
# Multiple volumes can be attached to the created EC2

variable "instances" {
    description = "Number of instances"
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
DESCRIPTION
}
variable "public_key_path" {
	description = <<DESCRIPTION
Path to the SSH public key to be used for authentication.
Ensure this keypair is added to your local SSH agent so provisioners can
connect. Example: ~/.ssh/id_rsa.pub
DESCRIPTION
}
variable "key_name" {
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
variable "ver" {
    description = <<DESCRIPTION
Server OS version info. 
For Linux since we are only using ubuntu variants, the valid versions are
12,14,16,18 - corresponding to ubuntu 12.04, 14.04, 16.04 and 18.04.
The default setting is 16 (ubuntu 16.04)
NOTE: That 12.04 is no longer supported by the ubuntu org, so it is recommended that
ubuntu 16.04 or 18.04 is used. 
DESCRIPTION
    default = "16"
}
variable "username" {
    description = <<DESCRIPTION
User name for administrative SSH login to the EC2 instance.
This username is used by terraform when provisioning the EC2 instance using the provisioners.
For Linux, this normally is whatever the default user account on the EC2 is
for example: on ubuntu it is "ubuntu" on Amazon linux it is ec2-user etc. 
DESCRIPTION
}
variable "root_volume" {
    description = "Root volume of the EC2 instance"
    default = { type = "gp2", size = 8, delete_on_termination = "true" }
}
variable "additional_volumes" {
    type = "list"
    description = <<DESCRIPTION
The following list of volume maps provide the data for the additional disks of the EC2 if needed.
Valid device_name values are "/dev/xvd[e-z]"
Valid type values are "gp2", "io1", "st1", "sc1" - but "gp2" is recommended in general as it has the best ROI.
Valid size values are - 8GB - 16TB. Linux workloads need at least 8GB minimum for testing. 
    { device_name = "/dev/xvde", type = "gp2", size = 8 },
    { device_name = "/dev/xvdf", type = "gp2", size = 20 }
DESCRIPTION
}
variable "files_to_copy" {
    type =  "list"
  description = <<DESCRIPTION
List of file copy Maps to be copied to EC2 instance
  {source = "myfile.txt", destination = "~/myfile.txt" }, 
  {source = "./myfolder", destination = "~/myfolder" } 
DESCRIPTION
}
variable "remote_commands" {
    type = "list"
    description = "List of commands to be run sequentially on the EC2 instance."
}
variable "amis" {
    description = <<DESCRIPTION
AMIs for Linuxbased on region. For Linux the coding of the key is <ver>-<region>. 
NOTE: The AMIs in this list are all picked with the above attributes.
DESCRIPTION
    default = { 
#        "12-us-east-1" = "ami-2f442839" # ebs, hvm
#        "12-us-east-1" = "ami-024a2614" # ebs-io1, hvm
        "12-us-east-1" = "ami-a04529b6" # ebs-ssd, hvm
#        "12-us-west-1" = "ami-a0b89fc0" # ebs, hvm
#        "12-us-west-1" = "ami-a1b89fc1" # ebs-io1, hvm
        "12-us-west-1" = "ami-aeb99ece" # ebs-ssd, hvm
#        "12-us-west-2" = "ami-830c94e3" # ebs, hvm
#        "12-us-west-2" = "ami-fc0b939c" # ebs-io1, hvm
#        "14-us-east-1" = "ami-07957d39ebba800d5" # ebs, hvm
#        "14-us-east-1" = "ami-06b9259c69d8ed7f3" # ebs-io1, hvm
        "14-us-east-1" = "ami-000b3a073fc20e415" # ebs-ssd, hvm
#        "14-us-west-1" = "ami-0a40aea49c501581d" # ebs, hvm
#        "14-us-west-1" = "ami-0037ca49b45845cbe" # ebs-io1, hvm
        "14-us-west-1" = "ami-0430743863c514c80" # ebs-ssd, hvm
#        "14-us-west-2" = "ami-038e6b679579b4ec1" # ebs, hvm
#        "14-us-west-2" = "ami-001e998553e998c5c" # ebs-io1, hvm
        "14-us-west-2" = "ami-0bac6fc47ad07c5f5" # ebs-ssd, hvm
        "16-us-east-1" = "ami-03e33c1cefd1d3d74"	# ebs-ssd, hvm
        "16-us-west-1" = "ami-0ee1a20d6b0c6a347"	# ebs-ssd, hvm
        "16-us-west-2" = "ami-0813245c0939ab3ca"	# ebs-ssd, hvm
#        "16-us-east-2" = "ami-be7753db"	# ebs-io1, hvm
        "16-us-east-2" = "ami-07d9419c80dc1113c"	# ebs-ssd, hvm
        "18-us-east-1" = "ami-05801d0a3c8e4c443"	# ebs-ssd, hvm
        "18-us-west-1" = "ami-0365b50e7a63e3bf1"	# ebs-ssd, hvm
        "18-us-east-2" = "ami-0a040c35ca945058a"	# ebs-ssd, hvm
        "18-us-west-2" = "ami-06ffade19910cbfc0"	# ebs-ssd, hvm
    }
}
locals {
    ami_key = "${var.ver}-${var.region}"
}
resource "aws_instance" "ec2" {
    count = "${var.instances}"
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
        Name = "${var.machine_name}-${count.index+1}"
        Project = "${var.project}"
        Platform = "Linux"
    }
}

# Used for provisioning of linux commands.  
resource "null_resource" "lrcmd" {
    depends_on = [ "aws_instance.ec2", "null_resource.lfcp" ]
    count = "${var.instances}"  
    triggers {
        ec2_id = "${element(aws_instance.ec2.*.id,count.index)}"
        filecopy = "${join(",",null_resource.lfcp.*.id)}" 
    }
    connection {
        host = "${element(aws_instance.ec2.*.public_ip,count.index)}"
        type = "ssh"
        user = "${var.username}" 
        private_key = "${file(var.private_key_path)}" 
    }
    provisioner "remote-exec" {
        inline = "${var.remote_commands}"
    }
}

locals {
    _fcp = "${length(var.files_to_copy)}"
    _fcp_count = "${local._fcp > 0 ? length(var.files_to_copy) : 0 }"
    fcp = "${var.instances > 0 ? (local._fcp_count * var.instances) : 0 }"    # No file copy if resource count is zero.
    fcp_divisor = "${local._fcp_count}"
}
# Used for copying files to the EC2. Currently we use this on Linux only.  
resource "null_resource" "lfcp" {
    depends_on = [ "aws_instance.ec2" ]
    count = "${local.fcp}"    # This will be > 0 if we need to copy files to the remote resource
    triggers {
        ec2_id = "${element(aws_instance.ec2.*.id,count.index)}"
    }
    connection {
        host = "${element(aws_instance.ec2.*.public_ip,count.index)}"
        type = "ssh"
        user = "${var.username}" 
        private_key = "${file(var.private_key_path)}" 
    }
    provisioner "file" {
        source = "${lookup(var.files_to_copy[(count.index % local.fcp_divisor)],"source")}"
        destination = "${lookup(var.files_to_copy[(count.index % local.fcp_divisor)],"destination")}"
    }
}

locals {
    _addlvol_count = "${length(var.additional_volumes)}" 
    addlvol_count = "${var.instances > 0 ? (local._addlvol_count * var.instances) : 0 }" # No additional volumes if count is zero
    addlvol_count_divisor = "${local._addlvol_count}"
}
# Used for creating additional volumes on the EC2. Data is supplied in the additional_volumes array
resource "aws_ebs_volume" "vebs" {
    count = "${local.addlvol_count}"
    availability_zone = "${element(aws_instance.ec2.*.availability_zone,count.index)}"
    type = "${lookup(var.additional_volumes[(count.index % local.addlvol_count_divisor)],"type")}"
    size = "${lookup(var.additional_volumes[(count.index % local.addlvol_count_divisor)],"size")}"
}

# Attaches the created additional volumes on the EC2. Same data supplied in the additional_volumes array is used
resource "aws_volume_attachment" "vattach" {
    count = "${local.addlvol_count}"
    device_name = "${lookup(var.additional_volumes[(count.index % local.addlvol_count_divisor)],"device_name")}"
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
