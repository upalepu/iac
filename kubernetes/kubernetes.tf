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
/* EXPERIMENTAL
locals {
    ebsvol_az = "${var.k8scfg["parm_region"]}a" # Converting region (e.g us-east-1) to AZ (e.g. us-east-1a)
}
# Used by the Kubernetes cluster for PersistentVolume if any pods need it. 
# Note: This will go away when the cluster is taken down.  
resource "aws_ebs_volume" "ebsvol" {
    depends_on = ["null_resource.k8scluster"]
    availability_zone = "${local.ebsvol.az}"
    size = "${var.k8scfg["parm_pvsize"]}"
    type = "${var.k8scfg["parm_pvtype"]}"
    tags {
        Name = "${var.k8scfg["tags_project"]}-ebs-pv"
        Project = "${var.k8scfg["tags_project"]}"
        Provider = "${var.k8scfg["tags_provider"]}"
    }
}
*/
resource "null_resource" "kops" {
    triggers {
        s3b_id = "${aws_s3_bucket.s3b.id}"
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
    _nsrecords = "${length(values(data.external.subhz_nsrecords.result))}"
}
resource "null_resource" "k8scluster" {
    depends_on = [ "data.external.subhz_nsrecords" ]
    triggers {
        k8sc_s3b_name = "${aws_s3_bucket.s3b.id}"
        nsrecords = "${local._nsrecords}"
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
created=0; tries=0; looplimit=5;	# Safety net to avoid forever loop. 
while ((!created && looplimit)); do	# Loop while create cluster fails and looplimit non-zero.
    ((tries++))
    echo -e "Creating kubernetes cluster ... [$tries]" 
    sleep 20s
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
    if (($?)); then 
        echo -e "Create cluster failed. Deleting cluster ..."
        kops delete cluster --name=${local._cluster_name} --state=${local._state} --yes 
    else
        created=1   # Create succeeded
    fi
    ((looplimit--))
done
if ((!created)); then echo -e "Failed to create cluster after [$tries] tries."; exit 1; fi

echo -e "Validating kubernetes cluster. This might take a few minutes, please wait ..." 
validated=0; tries=0; looplimit=8;	# Safety net to avoid forever loop. 
while ((!validated && looplimit)); do	# Loop while create cluster fails and looplimit non-zero.
    ((tries++))
    sleep 60s
    kops validate cluster --name=${local._cluster_name} --state=${local._state} 2>/dev/null
    if ((!$?)); then validated=1; else echo -e "Retrying [$tries] validation of kubernetes cluster ... "; continue; fi
    ((looplimit--))
done
if ((!validated)); then 
    echo -e "Failed to validate cluster after [$tries] tries. Deleting cluster ..."
    kops delete cluster --name=${local._cluster_name} --state=${local._state} --yes
    exit 1
fi

echo -e "\n\nDeploying Kubernetes dashboard ..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

echo -e "\n\nGetting Kubernetes master name ..."
k8smaster=$(kubectl cluster-info | grep "Kubernetes master" | sed -r -e "s/.*(https.*)/\1/g")
echo $k8smaster > k8smaster
echo -e "Saving the Kubernetes master name to the file 'k8smaster' for future reference"
echo -e "\n\nFrom any browser type $k8smaster/ui to access the dashboard"

echo -e "\n\nGetting admin user token (password) ..."
adminusertoken=$(kops get secrets kube --state=${local._state} --type=secret -oplaintext)
echo $adminusertoken > adminusertoken
echo -e "When logging into the Kubernetes dashboard for the first time,"
echo -e "username is 'admin' and password is the value in the file 'adminusertoken'."

echo -e "\n\nGetting admin service token ..."
adminsvctoken=$(kops get secrets admin --state=${local._state} --type=secret -oplaintext)
echo $adminsvctoken > adminsvctoken
echo -e "After supplying the username & password, you will get a second screen."
echo -e "Select 'token' and provide the admin service token found in the file 'adminsvctoken'."

if [[ ! -e ~/.bashrc ]]; then touch ~/.bashrc; fi
echo -e "export NAME=${local._cluster_name}" >> ~/.bashrc   # Sets it for future
echo -e "export KOPS_STATE_STORE=${local._state}" >> ~/.bashrc # Sets it for future
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
#        ebsvol_id = "${aws_ebs_volume.ebsvol.id}"
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
