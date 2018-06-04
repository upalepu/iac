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
}
module "iacec2" {
    source = "../modules/ec2"
    count = "${var.count}"
    project = "${var.project}"
    machine_name = "${var.project}-ec2"
    instance_type = "${var.ec2_type}"
    private_key_path = "${var.private_key_path}"
    public_key_path = "${var.public_key_path}"
    key_name = "${var.key_name}"
    region = "${var.region}"
	sg_ids = ["${module.myvpc.security_group}"]
	subnet_id = "${module.myvpc.subnet}"
    platform = "${var.platform}"
    ver = "${var.ver}"
    db = "${var.db}"
    username = "${var.username}"
    root_volume = "${var.rootvol}"
    additional_volumes = "${var.additional_volumes}"
    files_to_copy = "${var.files_to_copy}"
    remote_commands = "${var.remote_commands}"
}

output "iacec2_info" {
    description = "Ubuntu EC2 with iac & terraform installed & Network Info"
    value = {
        ec2_info = "${module.iacec2.ec2_info}"
        network_info = "${module.myvpc.network_info}"
    } 
}