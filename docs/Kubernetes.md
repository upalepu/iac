# Infrastructure as Code - Setting up for and creating a Kubernetes Cluster on AWS
The following instructions will enable you to create a Kubernetes Cluster on AWS. The cluster has full high availability capability and can be used for development/testing purposes. 
NOTE: This cluster will cost money on AWS as it creates and uses several machines, volumes etc. Don't forget to run terraform destroy after you are done with your experimenting to take down the cluster and keep your costs low. 

### Specific pre-requisites 

1) Make sure you have created the EC2 machine using the ***iacec2*** project. If you haven't done this stop and complete that project first. Click [here](./Iacec2.md) for details.    
2) Your favorite IDE or code editor (e.g. vscode, notepad++, vi etc.) 

### Steps to follow  

- SSH into the iacec2 machine using your favorite terminal program. SSH requires a user account, this should be  ***ubuntu***. You also need to provide a private key. This is the private key (.pem) file of the AWS account which was used to create the iacec2 machine. SSH also needs either the AWS ec2 ip address (e.g. ***35.172.216.152***) or host name (e.g. ***ec2-35-172-216-152.compute-1.amazonaws.com***) to complete the login. See example below.  

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
- Now you're ready to create the Kubernetes cluster. To do this, type the following command and let terraform take care of creating the cluster. If the terraform initialization succeeds, you will see something like the following. If there is a lot of red or terraform prompts you for an S3 bucket name. Go [here](./Troubleshooting.md) and search for ***backend*** to troubleshoot. 

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ terraform init -backend-config=tfs3b.cfg

Initializing the backend...

Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.external: version = "~> 1.0"
* provider.null: version = "~> 1.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
ubuntu@ip-10-0-1-42:~/iac/kubernetes$
```
- To create the Kubernetes cluster, type the following at the command prompt. This command will show the artifacts that terraform expects to create. You will be prompted to type "yes" for confirmation. Any other key cancels the command. If you typed "yes", terraform will create all the resources and exit.   

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ terraform apply
```
- You're almost at the end. Once terraform has completed the infrastructure creation, Kubernetes suggests that you validate the cluster. In order for this to happen correctly, wait for a few minutes before running the command to validate. Once the cluster is validated, you are ready to experiment with kubernetes.    

- Don't forget to run ***terraform destroy*** when you're done playing around. It will destroy all the artifacts created for the Kubernetes cluster. You can then exit from the SSH login of the ***iacec2*** machine.  

### Summary
Creating a kubernetes cluster is a fairly complex process with many steps in the overall process. While this can be done manually or via a script, doing it with Terraform has the unique advantage in that you can bring it all down at the push of a button. This project also shows how one can "bootstrap" an complete dev/test environment for playing with a kubernetes cluster.  


