# Create a VPC to launch our instances into
variable "security_group_description" {
	description = "Description of the security group"
	default = "Demo Security Group - demo-sg"
}

variable "security_group_name" {
	description = "Name of the security group"
	default = "demo-sg"
}
variable "project" {
	description = "Name of the project"
	default = "demo"
}

resource "aws_vpc" "vpc" {
	cidr_block = "10.0.0.0/16"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
    tags {
        Project = "${var.project}"
    }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "internet_gateway" {
	vpc_id = "${aws_vpc.vpc.id}"
    tags {
        Project = "${var.project}"
    }
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
	route_table_id         = "${aws_vpc.vpc.main_route_table_id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "subnet" {
	vpc_id                  = "${aws_vpc.vpc.id}"
	cidr_block              = "10.0.1.0/24"
	map_public_ip_on_launch = true
    tags {
        Project = "${var.project}"
    }
}

# Our security group to access the instances over SSH, RDP and HTTP
resource "aws_security_group" "security_group" {
	name        = "${var.security_group_name}"
	description = "${var.security_group_description}"
	vpc_id      = "${aws_vpc.vpc.id}"
    tags {
        Project = "${var.project}"
    }
}

# ingress rule for SSH access
resource "aws_security_group_rule" "allow_ssh_inbound" {
	type = "ingress"
	security_group_id = "${aws_security_group.security_group.id}"
	from_port   = 22
	to_port     = 22
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
}

# ingress rule for winrm access
resource "aws_security_group_rule" "allow_winrm_inbound" {
	type = "ingress"
	security_group_id = "${aws_security_group.security_group.id}"
	from_port   = 5985
	to_port     = 5985
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
}

# ingress rule for RDP access
resource "aws_security_group_rule" "allow_rdp_inbound" {
	type = "ingress"
	security_group_id = "${aws_security_group.security_group.id}"
	from_port   = 3389
	to_port     = 3389
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
}

# HTTP access from all
resource "aws_security_group_rule" "allow_http_inbound" {
	type = "ingress"
	security_group_id = "${aws_security_group.security_group.id}"
	from_port   = 80
	to_port     = 80
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
}

# HTTPS access from all
resource "aws_security_group_rule" "allow_https_inbound" {
	type = "ingress"
	security_group_id = "${aws_security_group.security_group.id}"
	from_port   = 443
	to_port     = 443
	protocol    = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
}

# Outbound internet access
resource "aws_security_group_rule" "allow_all_outbound" {
	type = "egress"
	security_group_id = "${aws_security_group.security_group.id}"
	from_port   = 0
	to_port     = 0
	protocol    = "-1"
	cidr_blocks = ["0.0.0.0/0"]
}

output "network_info" {
	description = "AWS Network Info."
	value = {
		vpc = "${aws_vpc.vpc.id}"
		internal_cidr_block = "${aws_vpc.vpc.cidr_block}"
		internet_gateway = "${aws_internet_gateway.internet_gateway.id}"
		internet_access_cidr_block = "${aws_route.internet_access.destination_cidr_block}"
		subnet = "${aws_subnet.subnet.id}"
		subnet_cidr_block = "${aws_subnet.subnet.cidr_block}"
		security_group = "${aws_security_group.security_group.id}"
	} 
}

output "vpc_id" {
	description = "AWS VPC ID"
	value = "${aws_vpc.vpc.id}"
}

output "security_group" {
	description = "AWS Security Group."
	value = "${aws_security_group.security_group.id}"
}

output "subnet" {
	description = "AWS Subnet."
	value = "${aws_subnet.subnet.id}"
}
