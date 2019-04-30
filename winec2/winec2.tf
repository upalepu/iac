# This Terraform configuration will create a Basic ubuntu EC2 machine in AWS
# The network module is used to setup a Basic VPC with SSH access
# The ec2 module is used to create the EC2 and attach additional disks as necessary.
# Basic level of provisioning can be done by uploading files and running rermote commands on the EC2 machine.
 provider "aws" {
	region = "${var.region}"
	version = "~> 1.6"
}
module "myvpc" {
	source = "../modules/network"
	project = "${var.project}"
	security_group_name = "${var.project}-sg"
	security_group_description = "${var.project} Security Group"
}
module "winec2" {
	source = "../modules/wec2"
	count = "${var.count}"
	project = "${var.project}"
	instance_type = "${var.ec2_type}"
	key_name = "${var.key_name}"
	admin_password = "${var.pwd}"
	region = "${var.region}"
	sg_ids = ["${module.myvpc.security_group}"]
	subnet_id = "${module.myvpc.subnets[0]}"
	ver = "${var.ver}"
	db = "${var.db}"
	username = "${var.username}"
	root_volume = "${var.rootvol}"
	additional_volumes = "${var.additional_volumes}"
	files_to_copy = "${var.files_to_copy}"
	remote_commands = "${var.remote_commands}"
}

output "winec2_info" {
	description = "Windows EC2 & Network Info"
	value = {
		ec2_info = "${module.winec2.wec2_info}"
		network_info = "${module.myvpc.network_info}"
	} 
}
