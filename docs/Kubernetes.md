# Infrastructure as Code - Setting up for and creating a Kubernetes Cluster on AWS

<style>
.twocol ~ * { width: 50%; float: left; box-sizing: border-box; padding-left: 1rem; }
.onecol ~ * { clear: both; width: 100%; padding-left: 0; }
</style>

The following instructions will enable you to create a Kubernetes Cluster on AWS. The cluster has full high availability capability and can be used for development/testing purposes.
NOTE: This cluster will cost money on AWS as it creates and uses several machines, volumes etc. Don't forget to run terraform destroy after you are done with your experimenting to take down the cluster and keep your costs low.

<div class="twocol"></div>

Here's how the system architecture looks like. For simplicity, only port 80 and 443 are shown here for http(s) connections. You can setup the VPC for allowing any kind of port access. SSH can also be limited only to your IP address for additional security, but you will have to set that up yourself. The iacec2 machine is loaded with Ubuntu, the iac project, terraform, aws commandline and an S3 bucket for storing Terraform state remotely. In addition the machine is configured to access AWS using the kops user account. This account will be used by Kubernetes, but can also serve the purpose of accessing AWS and experimenting with AWS command line utilities.

![AWS EC2 Kubernetes](./kubernetes.png "AWS EC2 Kubernetes")

<div class="onecol"></div>

## Pre-requisites

Make sure you have all the pre-requisites needed to successfully run this project by clicking [here.](./Prereqs.md) In addition, make sure you have created the EC2 machine using the ***iacec2*** project. If you haven't done this, stop here and complete that project first. Click [here](./Iacec2.md) for details on how to setup an ***iacec2*** machine.

- In addition, you will need a web domain. Either create one on AWS or if you already have an existing domain from a 3rd party provider you can use that. This project assumes you have a domain with AWS on Route53. If you have a 3rd party domain, there are a few manual steps to do before you can use this project. For more details on setting up domains, click [here.](./Domains.md)

## Steps to follow  

Overall, there are four sets of steps to be aware of: [Access](#access), [Configure](#cfg), [Create](#create) and [Destroy.](#destroy). Of these, the first three are important to get the Kubernetes cluster up and running and the last one is to take it down.  

### <a name="access"></a>Access

Before you do anything you need to make sure you are on the right machine. This step helps you to get to the ***iacec2*** machine which you created using the ***iacec2*** project.  

- SSH into the iacec2 machine using your favorite terminal program. SSH requires a user account, this should be  ***ubuntu***. You also need to provide a private key file. This is the private key (.pem) file of the AWS account which was used to create the iacec2 machine. SSH also needs either the AWS ec2 ip address (e.g. ***35.172.216.152***) or host name (e.g. ***ec2-35-172-216-152.compute-1.amazonaws.com***) to complete the login. See example below.  

```bash
testuser@testbox:~$ssh -i ~/.ssh/aws_user_pvt_key.pem ubuntu@35.172.216.152
```

- Once logged in, verify that ***terraform*** and ***aws*** command line utility are installed on the machine. If either of these is not installed, either this EC2 was not created using the iac/iacec2 project or there was a problem with the creation. Go back to the [iacec2](./Iacec2.md) project and make sure it was created properly.

```bash
ubuntu@ip-10-0-1-42:~$ terraform version
Terraform v0.11.7

ubuntu@ip-10-0-1-42:~$ aws --version
aws-cli/1.15.40 Python/3.5.2 Linux/4.4.0-1041-aws botocore/1.10.40
ubuntu@ip-10-0-1-42:~$
```

- Also verify that the ***iac*** directory exists in the home directory. If this directory is not present, check that this is the machine you created using the ***iacec2*** project. Go back to the [iacec2](./Iacec2.md) project and make sure it was created properly.

```bash
ubuntu@ip-10-0-1-42:~$ ls
iac
```

- Now it's time to configure the Kubernetes cluster. Go to the [Configure](#cfg) step.

### <a name="cfg"></a>Configure

- Change to ***iac/kubernetes*** and using your favorite editor (nano or vi) create a new file  ***terraform.tfvars*** and add the name of your hosted domain as shown below.  

```bash
ubuntu@ip-10-0-1-42:~$ cd iac/kubernetes/
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ nano terraform.tfvars
```

- In the editor add your hosted domain name as shown below. Your domain name will be something like this - ***yourdomain.ext***. For example,  ***yourcompany.com*** or ***yourorganization.org*** or ***yourorganization.net*** etc. After adding this information, save the ***terraform.tfvars*** file.

```bash
k8scfg = {
        parm_domain = "yourdomain.ext"
}
```

Next, setup Terraform to store its state remotely in the AWS s3 bucket. The S3 bucket was already created for you when you created the ***iacec2*** machine. All the configuration information was added to the ***tfs3b.cfg*** file which was uploaded as a part of the ***iacec2*** project.

- Check the ***iac/kubernetes*** directory for this file. The directory listing should show the ***tfs3b.cfg*** file.

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ ls -al
total 36
drwxrwxr-x  3 ubuntu ubuntu 4096 Jun 23 02:40 .
drwxrwxr-x 10 ubuntu ubuntu 4096 Jun 23 02:35 ..
-rw-rw-r--  1 ubuntu ubuntu 7410 Jun 23 02:35 kubernetes.tf
-rw-rw-r--  1 ubuntu ubuntu  863 Jun 23 02:35 kubernetes-vars.tf
-rw-rw-r--  1 ubuntu ubuntu 1410 Jun 23 02:35 nsrecords.sh
-rw-rw-r--  1 ubuntu ubuntu   44 Jun 23 02:40 terraform.tfvars
-rw-r--r--  1 ubuntu ubuntu  107 Jun 23 02:35 tfs3b.cfg
ubuntu@ip-10-0-1-42:~/iac/kubernetes$
```

- Now, at the bash prompt, type type the following command ***kubernetes$ terraform init -backend-config=tfs3b.cfg*** and let Terraform take care of the rest. The output will be as below if it succeeded, details have been omitted for brevity.

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ terraform init -backend-config=tfs3b.cfg

Initializing the backend...
Initializing provider plugins...
.
.
Terraform has been successfully initialized!
.
.
If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
ubuntu@ip-10-0-1-42:~/iac/kubernetes$
```

If the Terraform initialization fails or if Terraform prompts you for an S3 bucket name, stop the process by pressing [Ctrl+C], go to the Troubleshooting page by clicking [here](./Troubleshooting.md) and search for the word ***backend***. Follow the instructions to fix the issue and retry the Terraform initialization step.

- If initialization was successful go to the [Create](#create) step.

### <a name="create"></a>Create

- To create the Kubernetes cluster, type the following at the bash prompt. This command will show the artifacts that terraform expects to create. You will be prompted to type ***yes*** for confirmation. Any other key cancels the command. If you typed ***yes***, Terraform will create all the resources. The overall process takes a few minutes and there will be a lot of information displayed on the screen. A brief synopsis of parts of the output is shown below.

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ terraform apply
data.aws_route53_zone.hz: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:
.
.
Plan: 6 to add, 0 to change, 0 to destroy.
.
.
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
.
.
aws_s3_bucket.s3b: Creating...
  acceleration_status:         "" => "<computed>"
  acl:                         "" => "private"
  arn:                         "" => "<computed>"
  bucket:                      "" => "palepuweb-demo-kubernetes-state"
  bucket_domain_name:          "" => "<computed>"
  bucket_regional_domain_name: "" => "<computed>"
  force_destroy:               "" => "true"
  hosted_zone_id:              "" => "<computed>"
  region:                      "" => "us-east-1"
  request_payer:               "" => "<computed>"
  tags.%:                      "" => "3"
  tags.Name:                   "" => "demo-kubernetes-s3b"
  tags.Project:                "" => "demo-kubernetes"
  tags.Provider:               "" => "aws"
  versioning.#:                "" => "1"
  versioning.0.enabled:        "" => "false"
  versioning.0.mfa_delete:     "" => "false"
  website_domain:              "" => "<computed>"
  website_endpoint:            "" => "<computed>"
.
.
null_resource.k8scluster: Creating...
  triggers.%:             "" => "2"
  triggers.k8sc_s3b_name: "" => "palepuweb-demo-kubernetes-state"
  triggers.nsrecords:     "" => "4"
.
.
null_resource.k8scluster (local-exec): Cluster is starting.  It should be ready in a few minutes.

null_resource.k8scluster (local-exec): Suggestions:
null_resource.k8scluster (local-exec):  * validate cluster: kops validate cluster
null_resource.k8scluster (local-exec):  * list nodes: kubectl get nodes --show-labels
null_resource.k8scluster (local-exec):  * ssh to the master: ssh -i ~/.ssh/id_rsa admin@api.kubernetes.palepuweb.org
null_resource.k8scluster (local-exec):  * the admin user is specific to Debian. If not using Debian please use the appropriate user based on your OS.
null_resource.k8scluster (local-exec):  * read about installing addons at: https://github.com/kubernetes/kops/blob/master/docs/addons.md.
.
.
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

hz = {
  caller_reference = RISWorkflow-RD:fc5fc3fe-25e8-47fe-9ecd-72afbbf96a43
  comment = HostedZone created by Route53 Registrar
  resource_record_set_count = 2
}
k8scfg = {
  hz_id = Z16FLX7PL5856Z
  s3b_arn = arn:aws:s3:::yourdomain-demo-kubernetes-state
  s3b_id = yourdomain-demo-kubernetes-state
  s3b_region = us-east-1
  subhz_id = Z149E40G7CSZBH
}
subhz_records = {
  Value0 = ns-1768.awsdns-29.co.uk.
  Value1 = ns-627.awsdns-14.net.
  Value2 = ns-154.awsdns-19.com.
  Value3 = ns-1034.awsdns-01.org.
}
```

- You're almost at the end. At this point exit from the SSH login to the ***iacec2*** machine and log back in.

This will run the .bashrc file in the ***iacec2*** machine which will set the following environment variables ***NAME*** (holds the name of the Kubernetes cluster) and ***KOPS_STATE_STORE*** (holds the name of the S3 bucket where Kubernetes state is stored). Once logged back in, make sure you wait for 3 - 10 minutes to validate the cluster.

- The validate command is ***kops validate cluster***. When you run this command, the output will be as below if the Kubernetes cluster was created successfully.

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ kops validate cluster
Using cluster from kubectl context: kubernetes.yourdomain.ext

Validating cluster kubernetes.yourdomain.ext

INSTANCE GROUPS
NAME                    ROLE    MACHINETYPE     MIN     MAX     SUBNETS
master-us-east-1a       Master  t2.micro        1       1       us-east-1a
nodes                   Node    t2.micro        2       2       us-east-1a

NODE STATUS
NAME                            ROLE    READY
ip-172-20-42-13.ec2.internal    master  True
ip-172-20-57-166.ec2.internal   node    True
ip-172-20-60-16.ec2.internal    node    True

Your cluster kubernetes.yourdomain.ext is ready
ubuntu@ip-10-0-1-42:~/iac/kubernetes$
```

If the validate command came up with a error. Wait for some time before trying to validate the cluster again. It takes between 3 - 10 minutes for all the cluster master and nodes to be fully created and setup with proper access.

Now that the cluster has been created successfully, you can login to your AWS console and check out all the stuff that was created. There will be a master and two nodes in the cluster. You can see this in your EC2 service console. You can also see the S3 buckets. One is for Kubernetes and the other is for Terraform storing its state. In the Route53 console, you can see the kubernetes subdomain created under your domain.

Now that you've verified that everything is there, you can use ***kubectl*** to create and manage pods and other such Kubernetes artifacts. Once you are done experimenting with Kubernetes, don't forget to [Destroy](#destroy) the cluster.

### <a name="destroy"></a>Destroy

To destroy your Kubernetes cluster, follow the steps below.

- Run the command ***terraform destroy*** at the bash prompt. Note that you are running this command on the ***iacec2*** machine and not on your local machine. You will be prompted with a list of resources which will be destroyed and requested to type ***yes***. Any other key will cancel the command. Once you type ***yes*** the command will destroy all the artifacts created for the Kubernetes cluster. The output after the command is completed will look something like below. Parts of the output have been edited out for brevity.

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ terraform destroy
aws_vpc.vpc: Refreshing state... (ID: vpc-04d46999e8a521fb3)
aws_security_group.security_group: Refreshing state... (ID: sg-03bdd9f4f79c237a1)
.
.
Plan: 0 to add, 0 to change, 6 to destroy.

Do you really want to destroy?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
.
.
module.myvpc.aws_vpc.vpc: Destroying... (ID: vpc-04d46999e8a521fb3)
.
.
aws_route53_record.subhz_nsrecords: Still destroying... (ID: Z16FLX7PL5856Z_kubernetes.yourdomain.ext_NS, 40s elapsed)
null_resource.k8scluster (local-exec): volume:vol-04fdc2b01a7ac5f5a     still has dependencies, will retry
null_resource.k8scluster (local-exec): internet-gateway:igw-0779c73426907cf7f   still has dependencies, will retry
null_resource.k8scluster (local-exec): volume:vol-0b38e9032fe4defef     still has dependencies, will retry
.
.
null_resource.k8scluster (local-exec): Deleted kubectl config for kubernetes.yourdomain.ext

null_resource.k8scluster (local-exec): Deleted cluster: "kubernetes.yourdomain.ext"
null_resource.k8scluster (local-exec): Removing ~/.bashrc-kubernetes.bak
null_resource.k8scluster: Destruction complete after 1m27s
aws_route53_zone.subhz: Destroying... (ID: Z149E40G7CSZBH)
aws_s3_bucket.s3b: Destroying... (ID: yourdomain-demo-kubernetes-state)
aws_route53_zone.subhz: Destruction complete after 0s
aws_s3_bucket.s3b: Destruction complete after 1s

Destroy complete! Resources: 6 destroyed.
ubuntu@ip-10-0-1-42:~/iac/kubernetes$
```

At this point you can login to your AWS console and double check that there are no Kubernetes related infrastructure items. You will still have the ***iacec2*** machine and all artifacts that were created by the ***iacec2*** Terraform project.

Once the Kubernetes cluster is successfully destroyed, you should exit from the ***iacec2*** machine and switch to your local machine to destroy the ***iacec2*** machine and all associated infrastructure as well.

- Switch a bash prompt on your local machine, change to the ***iac/iacec2*** directory and run the ***terraform destroy*** command. This will destroy the ***iacec2*** machine along with everything related to Kubernetes. If everything went well, the output will look approximately like the following.

```bash
ubuntu@ubuntu:~/iac/iacec2$ terraform destroy
aws_iam_user.user: Refreshing state... (ID: kops)
aws_iam_group.group: Refreshing state... (ID: kopsgroup)
aws_vpc.vpc: Refreshing state... (ID: vpc-0f184d2f28234c5e4)
.
.
Plan: 0 to add, 0 to change, 25 to destroy.

Do you really want to destroy?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
.
.
module.myvpc.aws_vpc.vpc: Destroying... (ID: vpc-04d46999e8a521fb3)
module.myvpc.aws_vpc.vpc: Destruction complete after 1s

Destroy complete! Resources: 25 destroyed.
ubuntu@ubuntu:~/iac/iacec2$
```

That concludes this project. All AWS infrastructure artifacts are created and destroyed properly so there is no unncessary cost incurred. You can now login to your AWS account and double-check that the ***iacec2*** machine and associated artifacts like the VPC, security groups etc. are all gone.

## Summary

Creating a Kubernetes cluster is a lengthy process and it can be challenging to remove all the Kubernetes artifacts manually. This runs the risk of paying for compute resources unnecessarily. A bash script could be utilized to automate the cluster creation. However, one major benefit of Terraform is that it stores the state of the infrastructure in a safe location, which means that you can destroy the entire Kubernetes cluster environment with just one simple command. This project shows how one can "bootstrap" a complete dev/test environment with a Kubernetes cluster and take it down as easily.
