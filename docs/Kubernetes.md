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

## Steps to follow  

There are four sets of steps to follow: [Access](#access), [Configure](#cfg), [Create](#create) and [Destroy.](#destroy)

### <a name="access"></a>Access

- SSH into the iacec2 machine using your favorite terminal program. SSH requires a user account, this should be  ***ubuntu***. You also need to provide a private key file. This is the private key (.pem) file of the AWS account which was used to create the iacec2 machine. SSH also needs either the AWS ec2 ip address (e.g. ***35.172.216.152***) or host name (e.g. ***ec2-35-172-216-152.compute-1.amazonaws.com***) to complete the login. See example below.  

```bash
testuser@testbox:~$ssh -i ~/.ssh/aws_user_pvt_key.pem ubuntu@35.172.216.152
```

- Once logged in verify that ***terraform*** and ***aws*** command line utility are installed on the machine. If either of these is not installed, either this EC2 was not created using the iac/iacec2 project or there was a problem with the creation. Go back to the [iacec2](./Iacec2.md) project and make sure it was created properly.

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

- Now go to the [Configure](#cfg) step.

### <a name="cfg"></a>Configure

- Now change to ***iac/kubernetes*** and using your favorite editor (nano or vi) create a new file  ***terraform.tfvars*** and add the name of your hosted domain as shown below.  

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

Next, setup Terraform to have a remote state in the AWS s3 bucket. This information is already created in the ***tfs3b.cfg*** file which was uploaded as a part of the ***iacec2*** project.

- At a bash prompt, type type the following command ***kubernetes$ terraform init -backend-config=tfs3b.cfg*** and let Terraform take care of the rest. The output will be as below if it succeeded, details have been omitted for brevity.

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

- To create the Kubernetes cluster, type the following at a bash prompt. This command will show the artifacts that terraform expects to create. You will be prompted to type ***yes*** for confirmation. Any other key cancels the command. If you typed ***yes***, Terraform will create all the resources.

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ terraform apply
```

- You're almost at the end. At this point exit from the SSH login to the ***iacec2*** machine and log back in.

This will run the .bashrc file in the ***iacec2*** machine which will set the following environment variables ***NAME*** (holds the name of the Kubernetes cluster) and ***KOPS_STATE_STORE*** (holds the name of the S3 bucket where Kubernetes state is stored). Once logged back in, make sure you wait for 3 - 10 minutes to validate the cluster.

- The validate command is ***kops validate cluster***. When run the output will be as below if the Kubernetes cluster was created successfully.

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ kops validate cluster
output TBD

```

Now that the cluster has been created successfully, you can use ***kubectl*** to create and manage pods and other such Kubernetes artifacts. Once you are done experimenting with Kubernetes, don't forget to [Destroy](#destroy) the cluster.

### <a name="destroy"></a>Destroy

Now that you are ready to destroy your Kubernetes cluster, follow the steps below.

- Run the command ***terraform destroy*** at the bash prompt. It will destroy all the artifacts created for the Kubernetes cluster. You can then exit from the SSH login of the ***iacec2*** machine. Note that you are running this command on the ***iacec2*** machine and not on your local machine.


```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ terraform destroy
aws_vpc.vpc: Refreshing state... (ID: vpc-04d46999e8a521fb3)
aws_security_group.security_group: Refreshing state... (ID: sg-03bdd9f4f79c237a1)
.
.
.
.
module.myvpc.aws_vpc.vpc: Destroying... (ID: vpc-04d46999e8a521fb3)
module.myvpc.aws_vpc.vpc: Destruction complete after 1s

Destroy complete! Resources: XX destroyed.
ubuntu@ip-10-0-1-42:~/iac/kubernetes$
```

Once the Kubernetes cluster is successfully destroyed, you need exit from the ***iacec2*** machine and switch to your local machine to destroy the ***iacec2*** machine and associated infrastructure as well.

- To destroy the ***iacec2*** machine, you should switch back to your local machine, change to the ***iac/iacec2*** directory and run the ***terraform destroy*** command. This will destroy the ***iacec2*** machine along with everything related to Kubernetes. For successful destruction, the output will look approximately like the following.

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ terraform destroy
aws_vpc.vpc: Refreshing state... (ID: vpc-04d46999e8a521fb3)
aws_security_group.security_group: Refreshing state... (ID: sg-03bdd9f4f79c237a1)
.
.
.
module.myvpc.aws_vpc.vpc: Destroying... (ID: vpc-04d46999e8a521fb3)
module.myvpc.aws_vpc.vpc: Destruction complete after 1s

Destroy complete! Resources: XX destroyed.
ubuntu@ip-10-0-1-42:~/iac/kubernetes$
```

That concludes this project. All AWS infrastructure artifacts are created and destroyed properly so there is no unncessary cost incurred. If you prefer, you can login to your AWS account and double-check that the Kubernetes cluster and all of the infrastructure items it created are no longer present.

## Summary

Creating a Kubernetes cluster is a lengthy process and it can be challenging to remove all the Kubernetes artifacts manually. This runs the risk of paying for compute resources unnecessarily. A bash script could be utilized to automate the cluster creation. However, one major benefit of Terraform is that it stores the state of the infrastructure in a safe location, which means that you can destroy the entire Kubernetes cluster environment with just one simple command. This project shows how one can "bootstrap" a complete dev/test environment with a Kubernetes cluster and take it down as easily.
