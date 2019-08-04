# This file contains variables which are referenced and used by the various terraform
# configuration files in this project.
# Most commonly needed variable are included here. 
# Changing the value in the variable will enable a different configuration to be created.
# See individual variable descriptions for information on how to change variables. 
variable "public_key_path" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {	default = "us-east-1" }
variable "project" { default = "demo-ubuntu" }
variable "ec2_type" { default = "t2.small" }
variable "ver" { default = "16" }
variable "instances" { default = "1" }
variable "username" { default = "ubuntu" }
variable "rootvol" { default = { type = "gp2", size = "15", delete_on_termination = "true" } }
variable "additional_volumes" { default = [] }
variable "files_to_copy" { default = [] }
variable "remote_commands" {
	type = "list"
	default = [
		"sudo apt-get -y update",
	]
}
