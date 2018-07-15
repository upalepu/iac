# This file contains variables which are referenced and used by the various terraform
# configuration files in this project.
# Most commonly needed variable are included here. 
# Changing the value in the variable will enable a different configuration to be created.
# See individual variable descriptions for information on how to change variables. 
variable "public_key_path" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {	default = "us-east-1" }
variable "project" { default = "demo-iacec2" }
variable "ec2_type" { default = "t2.small" }

variable "ver" { default = "16" }
variable "username" { default = "ubuntu" }
variable "rootvol" { default = { type = "gp2", size = "30", delete_on_termination = "true" } }

variable "additional_volumes" { default = [] }
variable "files_to_copy" { default = [] }
variable "remote_commands" {
	type = "list"
	default = [
		"sudo apt-get -y update",
		"sudo apt-get install -y jq",
		"git clone https://github.com/upalepu/iac.git",
		"cd $HOME/iac/helpers",
		"chmod +x *.sh",
		"./setupterraform.sh"
	]
}

variable "k8scfg" {
	type = "map"
	description = "AWS Configuration information for Kubernetes Cluster user name & group"
	default = {
		parm_k8sproj = "k8sgossip" # Valid options: Must be one of the dirs (kubernetes|k8sgossip in iac) 
		parm_group = "kopsgroup"
		parm_user = "kops"
		md_force_destroy = "false" # Experimental. "true" if "user" has to be deleted even if it has non-terraform access keys.
	}
}
