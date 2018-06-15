# This Terraform configuration will create a Basic ubuntu EC2 machine in AWS
# The network module is used to setup a Basic VPC with SSH access
# The ec2 module is used to create the EC2 and attach additional disks as necessary.
# Basic level of provisioning can be done by uploading files and running rermote commands on the EC2 machine.
 provider "aws" {
    region = "${var.region}"
	version = "~> 1.6"
}
variable "gpolicy_arn" {
    type = "list"
    description = "List of group policy arns needed by the Kubernetes group"
    default = [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/IAMFullAccess",
        "arn:aws:iam::aws:policy/AmazonVPCFullAccess",
    ]
}
resource "aws_iam_group" "group" {
    name = "${var.k8scfg["parm_group"]}"
    path = "/"
}
resource "aws_iam_group_policy_attachment" "gpa" {
    depends_on = [ "aws_iam_group.group" ]
    count = "${length(var.gpolicy_arn)}"
    group = "${var.k8scfg["parm_group"]}"
    policy_arn = "${element(var.gpolicy_arn, count.index)}"
}
resource "aws_iam_user" "user" {
    name = "${var.k8scfg["parm_user"]}"
    path = "/"
    force_destroy = "${var.k8scfg["md_force_destroy"]}"
}
resource "aws_iam_group_membership" "gm" {
    depends_on = [ "aws_iam_user.user", "aws_iam_group.group" ]
    name = "${var.k8scfg["parm_group"]}"
    group = "${var.k8scfg["parm_group"]}"
    users = [
        "${var.k8scfg["parm_user"]}",
    ]
}
resource "aws_iam_access_key" "cak" {
    depends_on = [ "aws_iam_user.user" ]
    user = "${var.k8scfg["parm_user"]}"
}
locals {
    # Creating command line for setting up aws cli with id= & secret=
    # Note: This cmd assumes setupawscli is in current directory. 
    _cmd = "${format("./setupawscli.sh id=%s secret=%s", "${aws_iam_access_key.cak.id}", "${aws_iam_access_key.cak.secret}")}"
    _setupawsclicmd = [ "${local._cmd}" ]
    _cmd2 = "${format("bucket = ${aws_s3_bucket.s3b.id}\nkey = ${aws_s3_bucket.s3b.id}/kubernetes\nregion = ${var.region}")}"
    _bkend = "tfs3b.cfg" 
}


resource "aws_s3_bucket" "s3b" {
    bucket = "${var.project}-terraform-state"
    acl    = "private"
    force_destroy = "true"
    region = "${var.region}"
    tags {
        Name = "${var.project}-s3b"
        Project = "${var.project}"
    }
    versioning { enabled = "true" }
}
module "myvpc" {
	source = "../modules/network"
    project = "${var.project}"
    security_group_name = "${var.project}-sg"
}
module "iacec2" {
    source = "../modules/ec2"
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
    # In addition to the commands specified in the vars file, we're also appending
    # the setupawscli cmd. Note that it expects the pwd to be in the helpers
    # directory.  
    remote_commands = "${concat("${var.remote_commands}","${local._setupawsclicmd}")}"
}

resource "null_resource" "bkendcfg" {
    triggers {
        s3b_id = "${aws_s3_bucket.s3b.id}"
    }
    
    provisioner "local-exec" {
        when = "create"
        # Using heredoc syntax for running multiple cmds
        # Inner EOL heredoc cmds is needed to output multi-line string to backend cfg file. 
        command = <<CMD
if [[ -e ./${local._bkend} ]]; then rm ./${local._bkend}; fi
touch ./${local._bkend}
cat >> ./${local._bkend} <<EOL 
${local._cmd2}
EOL
CMD
        interpreter = [ "/bin/bash", "-c" ] 
    }

    # Uninstall kops on destroy 
    provisioner "local-exec" {
        when = "destroy"
        command = "if [[ -e ./${local._bkend} ]]; then rm ./${local._bkend}; fi"
        interpreter = [ "/bin/bash", "-c" ]
    }
}
resource "null_resource" "bkendcp" {
    depends_on = [ "null_resource.bkendcfg" ]
    triggers { bkendcfg = "${local._cmd2}" }
    connection {
        host = "${element(module.iacec2.ec2_ip,count.index)}"
        type = "ssh"
        user = "${var.username}" 
        private_key = "${file(var.private_key_path)}" 
    }
    provisioner "file" { source = "./${local._bkend}", destination = "~/iac/kubernetes/${local._bkend}" }
}

output "iacec2_info" {
    description = "Ubuntu EC2 with iac & terraform installed & Network Info"
    value = {
        ec2_ip = "${module.iacec2.ec2_ip}"
        ec2_info = "${module.iacec2.ec2_info}"
        network_info = "${module.myvpc.network_info}"
        user_name = "${aws_iam_user.user.name}" 
        user_uid = "${aws_iam_user.user.unique_id}"
        user_arn = "${aws_iam_user.user.arn}"
        group_name = "${aws_iam_group.group.name}" 
        group_uid = "${aws_iam_group.group.unique_id}"
        group_arn = "${aws_iam_group.group.arn}"
        access_key_id = "${aws_iam_access_key.cak.id}"
        access_key_user = "${aws_iam_access_key.cak.user}"
        access_key_secret = "${aws_iam_access_key.cak.secret}"
        s3bucket_id = "${aws_s3_bucket.s3b.id}"
        s3bucket_arn = "${aws_s3_bucket.s3b.arn}"
        s3bucket_region = "${aws_s3_bucket.s3b.region}"
    } 
}
