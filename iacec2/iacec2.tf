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
    _bkend = "tfs3b.cfg" 
    _bkendpath = "./${local._bkend}"
    _tfstatekeypath = "kubernetes/terraform.tfstate"
    _s3bucket = "${aws_s3_bucket.s3b.id}"
    # Note: The escaped dbl quotes surrounding each of the %s format types are necessary for 
    # being output as-is into the bkend cfg file   
    _cmd2 = "${format("bucket = \"%s\"\nkey = \"%s\"\nregion = \"%s\"", local._s3bucket, local._tfstatekeypath, var.region)}"
    _addlcmds = [
        "echo  ${module.myvpc.vpc_id} > ~/iac/${var.k8scfg["parm_k8sproj"]}/vpc",
        "${local._cmd}" 
    ]

}

data "aws_iam_account_alias" "current" {}

resource "aws_s3_bucket" "s3b" {
    bucket = "${data.aws_iam_account_alias.current.account_alias}-${var.project}-terraform-state"
    acl    = "private"
    force_destroy = "true"
    region = "${var.region}"
    tags {
        Name = "${var.project}-s3b"
        Project = "${var.project}"
    }
    versioning { enabled = "true" }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "s3bpol" {
  bucket = "${aws_s3_bucket.s3b.id}"
  policy =<<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": { "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.s3b.id}"
        },
        {
            "Effect": "Allow",
            "Principal": { "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
            "Action": [ "s3:GetObject", "s3:PutObject" ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.s3b.id}/${local._tfstatekeypath}"
        }
    ]
}
POLICY
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
    ver = "${var.ver}"
    username = "${var.username}"
    root_volume = "${var.rootvol}"
    additional_volumes = "${var.additional_volumes}"
    files_to_copy = "${var.files_to_copy}"
    # In addition to the commands specified in the vars file, we're also appending
    # a couple of addl cmds. the setupawscli cmd and the vpc file create cmd.
    # directory.  
    remote_commands = "${concat("${var.remote_commands}","${local._addlcmds}")}"
}

# This resource creates the file which contains the backend config data for terraform
# It's used by the k8sgossip and kubernetes projects as a convenience. 
# The variable local._cmd2 contains the information. 
resource "null_resource" "bkendcfg" {
    triggers {
        s3b_id = "${aws_s3_bucket.s3b.id}"
    }
    
    provisioner "local-exec" {
        when = "create"
        # Using heredoc syntax for running multiple cmds
        # Inner EOL heredoc cmds is needed to output multi-line string to backend cfg file. 
        command = <<CMD
if [[ -e ${local._bkendpath} ]]; then rm ${local._bkendpath}; fi
touch ${local._bkendpath}
cat >> ${local._bkendpath} <<EOL 
${local._cmd2}
EOL
CMD
        interpreter = [ "/bin/bash", "-c" ] 
    }

    # Delete bkendcfg file.  
    provisioner "local-exec" {
        when = "destroy"
        command = "if [[ -e ${local._bkendpath} ]]; then rm ${local._bkendpath}; fi"
        interpreter = [ "/bin/bash", "-c" ]
    }
}
# This resource is used to copy the backend config file to the appropriate kubernetes project 
# directory on the iacec2 machine. 
# There are two kubernetes projects currently. "kubernetes" & "k8sgossip"
# They differ in that the k8sgossip project doesn't require an external Route53 based (or other) DNS
# for creating a kubernetes cluster.
# The parm_k8sproj variable should be set to one of the above. It defaults to k8sgossip. 
resource "null_resource" "bkendcp" {
    depends_on = [ "null_resource.bkendcfg", "module.iacec2" ]
    triggers { bkendcfg = "${local._cmd2}", bkendpath = "${local._bkendpath}" }
    connection {
        host = "${element(module.iacec2.ec2_ip,count.index)}"
        type = "ssh"
        user = "${var.username}" 
        private_key = "${file(var.private_key_path)}" 
    }
    provisioner "file" { source = "${local._bkendpath}", destination = "~/iac/${var.k8scfg["parm_k8sproj"]}/${local._bkend}" }
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
