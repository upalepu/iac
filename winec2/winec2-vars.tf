# This file contains variables which are referenced and used by the various terraform
# configuration files in this project.
# Most commonly needed variable are included here. 
# Changing the value in the variable will enable a different configuration to be created.
# See individual variable descriptions for information on how to change variables. 
variable "count" { default = 1 }
variable "project" { default = "demo-winec2" }
variable "ec2_type" { default = "t2.small" }
variable "key_name" {}
variable "pwd" {}
variable "region" { default = "us-east-1" }
variable "ver" { default = "2016" }
variable "db" { default = "none" }
variable "username" { default = "Administrator" }
variable "rootvol" { type = "map", default = { type = "gp2", size = "40", delete_on_termination = "true" } }
variable "additional_volumes" { type = "list", default = [] }
variable "files_to_copy" { type = "list", default = [ { source = "../helpers/basiciis.ps1", destination = "c:\\basiciis.ps1" } ] }
variable "remote_commands" { 
    type = "list", 
    default = [
        "cd c:\\",
        "powershell c:\\basiciis.ps1"
    ] 
}
