# NOTE: Explicit dependencies need to be set for items otherwise creation will fail. 
provider "aws" {
    region = "${var.k8scfg["parm_region"]}"
	version = "~> 1.6"
}

terraform { backend "s3" {} }

data "aws_route53_zone" "hz" {
    name = "${var.k8scfg["parm_domain"]}"
}
resource "aws_route53_zone" "subhz" {
    name = "${var.k8scfg["parm_subdomain"]}.${var.k8scfg["parm_domain"]}"
    comment = "${var.k8scfg["parm_comment"]}"
    tags {
        Name = "${var.k8scfg["tags_project"]}-subhz"
        Project = "${var.k8scfg["tags_project"]}"
        Provider = "${var.k8scfg["tags_provider"]}"
    }
}
resource "aws_route53_record" "subhz_nsrecords" {
    depends_on = [ "aws_route53_zone.subhz" ] 
    zone_id = "${data.aws_route53_zone.hz.zone_id}"
    name    = "${var.k8scfg["parm_subdomain"]}.${var.k8scfg["parm_domain"]}"
    type    = "NS"
    ttl     = "300"
    records = ["${values(data.external.subhz_nsrecords.result)}"]
}
data "external" "subhz_nsrecords" {
    program = [ "/bin/bash", "nsrecords.sh" ] 
    query = {
        # "hosted_zone is passed in as json to the program nsrecords.sh"
        hosted_zone = "${aws_route53_zone.subhz.id}"
    }
    # Results are returned in "result" attribute
}
resource "aws_s3_bucket" "s3b" {
    bucket = "${replace(var.k8scfg["parm_domain"],"/\\..*/","")}-${var.k8scfg["tags_project"]}-state"
    acl    = "private"
    force_destroy = "true"
    region = "${var.k8scfg["parm_region"]}"
    tags {
        Name = "${var.k8scfg["tags_project"]}-s3b"
        Project = "${var.k8scfg["tags_project"]}"
        Provider = "${var.k8scfg["tags_provider"]}"
    }
    versioning {
        enabled = "${var.k8scfg["parm_versioning"]}"
    }
}

resource "null_resource" "kops" {
    triggers {
        s3b_id = "${aws_s3_bucket.s3b.id}"
        subhz_id = "${aws_route53_zone.subhz.zone_id}"
    }
    
    provisioner "local-exec" {
        when = "create"
        # Using heredoc syntax for running multiple cmds
        command = <<CMD
wget -O kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x ./kops
sudo mv ./kops /usr/local/bin/
CMD
        interpreter = [ "/bin/bash", "-c" ] 
    }

    # Uninstall kops on destroy 
    provisioner "local-exec" {
        when = "destroy"
        command = "KOPS=$(which kops); if [[ -e \"$KOPS\" ]]; then sudo rm $KOPS; fi"
        interpreter = [ "/bin/bash", "-c" ]
    }
}

resource "null_resource" "kubectl" {
    triggers {
        s3b_id = "${aws_s3_bucket.s3b.id}"
        subhz_id = "${aws_route53_zone.subhz.zone_id}"
    }
    
    provisioner "local-exec" {
        when = "create"
        # Using heredoc syntax for running multiple cmds
        command = <<CMD
wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/
CMD
        interpreter = [ "/bin/bash", "-c" ] 
    }

    # Uninstall kops on destroy 
    provisioner "local-exec" {
        when = "destroy"
        command = "KUBECTL=$(which kubectl); if [[ -e \"$KUBECTL\" ]]; then sudo rm $KUBECTL; fi"
        interpreter = [ "/bin/bash", "-c" ]
    }
}

locals {
    _cluster_name = "${var.k8scfg["parm_subdomain"]}.${var.k8scfg["parm_domain"]}"
    _state = "s3://${aws_s3_bucket.s3b.id}"

}
resource "null_resource" "k8scluster" {
    depends_on = [
        "null_resource.kops",
        "null_resource.kubectl",
        "data.external.subhz_nsrecords",
    ]
    triggers {
        k8sc_name = "${var.k8scfg["parm_subdomain"]}.${var.k8scfg["parm_domain"]}"
        k8sc_s3b_name = "${aws_s3_bucket.s3b.id}"
        k8s_subhz_nsrecords = "${data.external.subhz_nsrecords.result}"
    }
    
    provisioner "local-exec" {
        when = "create"
        # Using heredoc syntax for running multiple cmds
        # First we check to see if a public key for ssh access by kops is already present. If so we delete it.  
        # Now we create a public key for ssh access by kops to the various kops systems. 
        # NOTE: kops assumes a key-pair id_rsa in the .ssh directory. So the ssh-keygen cmd is important.  
        # admin is the user name required for Debian. (Seems like kops defaults to using debian for its cluster machines)
        # Then we create the cluster. 
        # Then we copy the export commands for the env variables for use by kops into the .bashrc file. 
        #   
        command = <<CMD
if [[ -e ~/.ssh/id_rsa || -e ~/.ssh/id_rsa.pub ]]; then rm ~/.ssh/id_rs*; fi
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa; if (($?)); then exit 1; fi
kops create cluster \
--cloud=aws \
--name=${local._cluster_name} \
--state=${local._state} \
--zones=${var.k8scfg["parm_region"]}a \
--node-count=${var.k8scfg["parm_nodes"]} \
--node-size=${var.k8scfg["parm_nodetype"]} \
--master-size=${var.k8scfg["parm_mastertype"]} \
--dns-zone=${local._cluster_name} \
--yes
if (($?)); then exit 1; fi
if [[ ! -e ~/.bashrc ]]; then touch ~/.bashrc; fi
echo -e "export NAME=${local._cluster_name}" >> ~/.bashrc
echo -e "export KOPS_STATE_STORE=${local._state}" >> ~/.bashrc
CMD
        interpreter = [ "/bin/bash", "-c" ] 
    }

    # Unset the exported variables on destroy 
    # NOTE: echo "-e" for redirecting to the .bashrc is not used because it processes the \ in the file. 
    # Also putting dbl quotes around the file names won't work as bash can't expand the ~ charcter.    
    provisioner "local-exec" {
        when = "destroy"
        command = <<CMD
kops delete cluster --name=${local._cluster_name} --state=${local._state} --yes
if (($?)); then exit 1; fi
mv ~/.bashrc ~/.bashrc-kubernetes.bak
touch ~/.bashrc
while IFS= read -r line; do
	echo -e "$line" | grep "NAME" > /dev/null; if((!$?)); then continue; fi
	echo -e "$line" | grep "KOPS_STATE_STORE" > /dev/null; if((!$?)); then continue; fi
	echo "$line" >> ~/.bashrc
done < ~/.bashrc-kubernetes.bak
if (($?)); then 
    echo -e "Error updating ~/.bashrc. Restoring backup"; mv ~/.bashrc-kubernetes.bak ~/.bashrc
else
	echo -e "Removing ~/.bashrc-kubernetes.bak"; rm ~/.bashrc-kubernetes.bak
fi
unset NAME; unset KOPS_STATE_STORE
CMD
        interpreter = [ "/bin/bash", "-c" ]
    }
}

output "k8scfg" { 
    value = {
        hz_id = "${data.aws_route53_zone.hz.zone_id}"    
        subhz_id = "${aws_route53_zone.subhz.zone_id}"
        s3b_id = "${aws_s3_bucket.s3b.id}"
        s3b_arn = "${aws_s3_bucket.s3b.arn}"
        s3b_region = "${aws_s3_bucket.s3b.region}"
    }
}

output "subhz_records" {
    value = "${data.external.subhz_nsrecords.result}"
}
output "hz" {
    value = {
        caller_reference = "${data.aws_route53_zone.hz.caller_reference}"
        comment = "${data.aws_route53_zone.hz.comment}"
        resource_record_set_count = "${data.aws_route53_zone.hz.resource_record_set_count}"      
    } 
}
