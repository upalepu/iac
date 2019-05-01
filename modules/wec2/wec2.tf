# This is a module file which describes an aws ec2 instance
# It can create multiple Windows EC2 machines in AWS
# It assumes that the provider is specified in the calling parent
# Multiple volumes can be attached to the created EC2

provider "null" {
	version = "~> 1.0"
}

variable "count" {
	description = "Count of instances"
	default     = 1
}

variable "project" {
	description = "Name of the project. This will be added to the Project tag"
	default     = "demo"
}

variable "instance_type" {
	description = "AWS EC2 instance type"
}

variable "key_name" {
	description = <<DESCRIPTION
Name of the AWS key to be used for access. This is usually created when a user is created 
in the AWS account.
NOTE: This needs to be an existing key and preferably only to be used for this project
to ensure security. The private pem file for this key must be kept in a safe location. 
DESCRIPTION
}

variable "admin_password" {
	description = <<DESCRIPTION
Admin password for the windows EC2 machine. This is used to access the machine using winrm.
DESCRIPTION
}

variable "region" {
	description = "AWS region to launch servers."
	default     = "us-east-1"
}

variable "sg_ids" {
	type        = "list"
	description = "List of security group ids"
}

variable "subnet_id" {
	description = "Subnet id of the VPC into which the AMI is launched"
}

variable "ver" {
	description = <<DESCRIPTION
For Windows, the version numbers are 2012, 2012R2 and 2016 corresponding to
Windows 2012, 2012 R2 Server and Windows 2016 Server.  
DESCRIPTION
	default = "2016"
}

variable "db" {
	description = "Is MS SQL Server Standard or Enterprise installed. Valid values are [ssql|esql|none]."
	default     = "none"
}

variable "username" {
	description = <<DESCRIPTION
For Windows, this normally is the "Administrator". 
DESCRIPTION
	default = "Administrator"
}

variable "root_volume" {
	description = "Root volume of the Windows EC2 instance"
	default = { type = "gp2", size = 60, delete_on_termination = "true"  }
}

variable "additional_volumes" {
	type        = "list"
	description = <<DESCRIPTION
	List of Volume Maps (in addition to root volume) attached to the EC2 instance.
	Valid device_name values are "/dev/xvd[e-z]"
	Valid type values are "gp2", "io1", "st1", "sc1" - but "gp2" is recommended in general as it has the best ROI.
	Valid size values are - 8GB - 16TB. Windows workloads need at least 40GB minimum for testing. 
	{ device_name = "/dev/xvde", type = "gp2", size = 40 },
	{ device_name = "/dev/xvdf", type = "gp2", size = 100 }
DESCRIPTION
}

variable "files_to_copy" {
	type = "list"
	description = <<DESCRIPTION
List of file copy Maps to be copied to EC2 instance
NOTE: The Windows path names should have '\\' to ensure that terraform doesn't treat it as an escape character 
	{source = "myfile.txt", destination = "C:\\myfile.txt" }, 
	{source = "./myfolder", destination = "C:\\myfolder" } 
DESCRIPTION
}

variable "remote_commands" {
	type        = "list"
	description = "List of command (strings) to be run sequentially on the EC2 instance."
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
		"2012R2-ssql-us-east-1" = "ami-058cfbc910c735dbf"
		"2012R2-esql-us-east-1" = "ami-070ec27de05d06e71"
		"2012R2-none-us-east-1" = "ami-0b6158cfa2ae7b493"
		"2016-esql-us-east-1"   = "ami-0644d9f135284ca88"
		"2016-ssql-us-east-1"   = "ami-05b632586043f1663"
		"2016-none-us-east-1"   = "ami-0a9d418cd78849a6c"
		"2019-none-us-east-1" = "ami-0204606704df03e7e"
		"2019-ssql-us-east-1" = "ami-0e876724c7020a377"
		"2019-esql-us-east-1" = "ami-0bbf266c213082bb2"
		"2012R2-ssql-us-west-1" = "ami-0028cc9fee9893815"
		"2012R2-esql-us-west-1" = "ami-0a07c9018bbf9c85f"
		"2012R2-none-us-west-1" = "ami-0d4f8a9abc53cca9c"
		"2016-esql-us-west-1"   = "ami-07f2c906675c55c37"
		"2016-ssql-us-west-1"   = "ami-06087c0b9b94100b1"
		"2016-none-us-west-1"   = "ami-0d089c9a817ea8b89"
		"2019-none-us-west-1" = "ami-0349ec1b04afc2f46"
		"2019-ssql-us-west-1" = "ami-0e8c4b97ebd30e24a"
		"2019-esql-us-west-1" = "ami-0a0eac3072cc6959c"
	}
}

locals {

	machine_name = "${var.project}-win-ec2"
	type    = "winrm"
	ami_key = "${var.ver}-${var.db}-${var.region}"
}

data "template_file" "win_init" {
	### WINRM and Powershell Bootstrap scrtips/setup for Windows EC2. Goes into user_data upon EC2 instance creation.
	template = <<EOF
	 <script>
			winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config @{MaxEnvelopeSizekb="8000" } & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
	 </script>
	 <powershell>
			netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
		 	$admin = [ADSI]("WinNT://./${var.username}, user")
		 	$admin.SetPassword("${var.admin_password}")
	 </powershell>
EOF
	vars {
		username = "${var.username}"
		admin_password = "${var.admin_password}"
	}
}

resource "aws_instance" "wec2" {
	count                  = "${var.count}"
	instance_type          = "${var.instance_type}"
	ami                    = "${lookup(var.amis,local.ami_key)}"
	vpc_security_group_ids = ["${var.sg_ids}"]
	subnet_id              = "${var.subnet_id}"
	key_name               = "${var.key_name}"      # If this is not present we can't ssh into the system. 
	user_data              = "${data.template_file.win_init.rendered}"

	root_block_device {
		volume_type           = "${lookup(var.root_volume,"type")}"
		volume_size           = "${lookup(var.root_volume,"size")}"
		delete_on_termination = "${lookup(var.root_volume,"delete_on_termination")}"
	}

	tags {
		Name     = "${local.machine_name}-${count.index+1}"
		Project  = "${var.project}"
		Platform = "Windows"
	}
}

# Used for provisioning of commands on a Windows ec2  

resource "null_resource" "wrcmd" {
	depends_on = ["aws_instance.wec2", "null_resource.wfc"]
	count      = "${var.count}"

	triggers {
		ec2_id = "${element(aws_instance.wec2.*.id,count.index)}"
		filecopy            = "${join(",",null_resource.wfc.*.id)}"
	}

	# Wait for a min to make sure the Windows instance is properly booted up. 
		connection {
		host        = "${element(aws_instance.wec2.*.public_ip,count.index)}"
		type        = "${local.type}"
		user        = "${var.username}"
		password    = "${var.admin_password}"
		agent = "false"
		insecure = "true"
	}

	provisioner "remote-exec" {
		inline = "${var.remote_commands}"
	}
}

locals {
	_wfc_count        = "${length(var.files_to_copy)}"
	wfc_count         = "${var.count > 0 ? (local._wfc_count * var.count) : 0 }" # No file copy if resource count is zero.
	wfc_count_divisor = "${local._wfc_count}"
}

# Used for copying files to the windows EC2.  
resource "null_resource" "wfc" {
	depends_on = ["aws_instance.wec2"]
	count      = "${local.wfc_count}" # This will be > 0 if we need to copy files to the remote resource

	triggers {
		ec2_id = "${element(aws_instance.wec2.*.id,count.index)}"
	}

	connection {
		host        = "${element(aws_instance.wec2.*.public_ip,count.index)}"
		type        = "${local.type}"
		user        = "${var.username}"
		password    = "${var.admin_password}"
		agent = "false"
		insecure = "true"
	}

	provisioner "file" {
		source      = "${lookup(var.files_to_copy[(count.index % local.wfc_count_divisor)],"source")}"
		destination = "${lookup(var.files_to_copy[(count.index % local.wfc_count_divisor)],"destination")}"
	}
}

locals {
	_addlvol_count        = "${length(var.additional_volumes)}"
	addlvol_count         = "${var.count > 0 ? (local._addlvol_count * var.count) : 0 }" # No additional volumes if count is zero
	addlvol_count_divisor = "${local._addlvol_count}"
}

# Used for creating additional volumes on the EC2. Data is supplied in the additional_volumes array
resource "aws_ebs_volume" "vebs" {
	count             = "${local.addlvol_count}"
	availability_zone = "${element(aws_instance.wec2.*.availability_zone,count.index)}"
	type              = "${lookup(var.additional_volumes[(count.index % local.addlvol_count_divisor)],"type")}"
	size              = "${lookup(var.additional_volumes[(count.index % local.addlvol_count_divisor)],"size")}"
}

# Attaches the created additional volumes on the EC2. Same data supplied in the additional_volumes array is used
resource "aws_volume_attachment" "vattach" {
	count       = "${local.addlvol_count}"
	device_name = "${lookup(var.additional_volumes[(count.index % local.addlvol_count_divisor)],"device_name")}"
	instance_id = "${element(aws_instance.wec2.*.id,count.index)}"
	volume_id   = "${element(aws_ebs_volume.vebs.*.id,count.index)}"
}

output "wec2_info" {
	description = "Windows EC2 instance information."

	value = {
		public_dns_ip                   = "${zipmap(aws_instance.wec2.*.public_dns,aws_instance.wec2.*.public_ip)}"
		root_volume                     = "${aws_instance.wec2.*.root_block_device}"
		additional_volumes.device_names = "[${join(",",aws_volume_attachment.vattach.*.device_name)}]"
		additional_volumes.types        = "[${join(",",aws_ebs_volume.vebs.*.type)}]"
		additional_volumes.sizes        = "[${join(",",aws_ebs_volume.vebs.*.size)}]"
	}
}

output "wec2_ip" {
	description = "Windows EC2 instance id."
	value       = "${aws_instance.wec2.*.public_ip}"
}
