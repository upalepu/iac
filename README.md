# Infrastructure as Code
Having the ability to create your own virtual data center in just a couple of minutes is a very powerful feeling. It can be helpful for creating demo environments, testing and validation and even production environments if designed well. More importantly, being able to scale up/down your infrastructure automatically and take it all down is very cost efficient, convenient and powerful. This project is an attempt at creating a few sample environments in AWS using Terraform and bash scripting. For a brief synopsis on the folder structure and how to use Terraform, click [here.](#tfo)     

The table below lists the various cloud infrastructure artifacts which can be created using the resources in this folder. Instructions for using each type of artifact are also provided. 

Name|Cloud Platform|Artifact|Status|Description
---|---|---|---|---
ubuntu|AWS|EC2|Stable|Ubuntu linux EC2 machine in isolated VPC with SSH access 

[comment]: # (Upcoming items)
[comment]: # (windows|AWS|EC2|Not Done|Windows Server Basic|)

To try out creating your own infrastructure using code, either clone this project using git or download it to your local machine and try it out.

```bash
ubuntu@ubuntu:~$git clone https://github.com/upalepu/iac.git
```

---
## *General pre-requisites* 

1) You will need an AWS Account. If you don't have an account, sign up for free [here.](https://aws.amazon.com/free/)   
2) You will also need your AWS ***Access Key Id*** and ***Secret Access Key***. Check out details on how to get these [here.](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html)
If you don't have these or lost them you can recreate these. Check out details [here.](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)    
3) You will need the AWS Commandline Interface (CLI) installed on your local machine. For a quick way to install the AWS CLI on your local machine, follow the instructions [here.](#awsclii)       
4) You will need ***terraform*** installed on your local machine. Check out details [here.](#tii)

---

## *To create your own Ubuntu Machines on AWS* 

The following instructions will enable you to create multiple ubuntu EC2 machines within a dedicated Virtual private Cloud (VPC) in AWS. You can also provision these machines with any applications you require. Terraform is capable of basic provisioning of your machines, but for advanced application provisioning, you will be better off using a dedicated provisioning or configuration management software like Chef, Puppet, Ansible or Salt.

### Specific pre-requisites 

1) Your favorite IDE or code editor (e.g. vscode, notepad++, vi etc.)

### Steps to follow  

- Switch to the ***ubuntu*** sub-folder in the ***iac*** project and open the ***ubuntu-vars.tf*** which contains all the configurable variables
- Set the appropriate variables. At a minimum, the following variables need to be updated: ***public_key_path, private_key_path & key_name***. Provide the required information for each of these variables in the ***default*** key as shown below.   

```bash
variable "public_key_path" {
	description = <<DESCRIPTION
Authentication for SSH Access to AWS Linux EC2 machines. 
Path to the SSH public key to be used for authentication. 
This is the key file that AWS creates and includes in every EC2 machine.
Linux Example: "~/.ssh/my_aws_public_key.pub"
NOTE: This only is required for Linux machines.
DESCRIPTION
	default = "<your public key path>"
}
variable "private_key_path" {
  	description = <<DESCRIPTION
Private key file which AWS provides for your specific user account. 
This file path should be supplied so Terraform can login to the AWS EC2 machine 
and do remote administration tasks.
Linux Example: "~/.ssh/my_aws_private_key.pem"
DESCRIPTION
	default = "<your private key path>"
}
variable "key_name" {
  	description = <<DESCRIPTION
This is the name of the Key Pair in your AWS account that you are using.
You will be able to find this in the AWS console under "Key Pairs". 
DESCRIPTION
	default = "<your AWS key name>"
}  
```
- The default AWS ***region*** is set to *us-east-1*. If using the EC2 machine for testing and demo, this can be left unchanged.
- ***project*** needs to **only** be set if the default value is not acceptable. 
- Default ***ec2_type*** is *t2.small*. If the machine will be used as a server, a *t2.medium* may be a better choice. For additional AWS machine types check [here.](https://aws.amazon.com/ec2/instance-types/) 
- The ***count*** variable needs to be set **only** if more than one EC2 machine needs to be created.   
- ***platform*** is *linux* so nothing to be done here.
- For ubuntu 16.04, nothing has to be set on the ***ver*** variable. If ubuntu 14.04 or ubuntu 12.04 is needed, you can change this to "14" or "12" respectively. 
- The ***db*** variable is used only for windows EC2 machines, so it can be left alone. 
- The other variables can be left to their default values.
- Once all the variables have been set, run the ***terraform init*** command. The plugins will be installed and the system will be chacked for proper dependencies. If there are no errors you can go to the next step.  
```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform init
```
- Now run the ***terraform apply*** command. Type "yes" when prompted by the system after you have reviewed the items to be created. If one ubuntu machine is created, there will be about 14 items created. Note that this includes all the items in the VPC.   
```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform apply
```
- That's it! Your AWS EC2 ubuntu machine is now created and ready for use. To verify that the machine is available, SSH into the machine from a bash command prompt and verify that the machine is up and running. 

### Summary
Creating an ubuntu EC2 machine was as simple as specifying a few configuration parameters in the ubuntu-vars.tf file and running terraform. Terraform does the hard lifting and creates the EC2 machines.  

---

## <a name="tfo"></a>*Folder structure and Terraform usage overview*
Terraform uses a declarative language to setup and configure infrastructure. Plugins for various providers (e.g. AWS, GCP, Azure etc.) are available which enable you to create infrastructure configurations which are agnostic to the specific provider. With well designed declaration files, Terraform enables highly scalable infrastructures. 

### Folder structure
The folder structure for this project is designed for modularity and is as follows:
- ***iac*** (root folder)
  - ***helpers*** (contains bash script files and other files used for remote commands)
  - ***modules*** (contains reusable terraform modules)
    - ***ec2*** (module for creating ec2 machines)
    - ***network*** (module for creating the virtual private cloud in AWS)
  - ***infrastructure folder*** (e.g. ubuntu - contains the main terraform and vars files for each type of machine infrastructure to be created )
  - ***infrastructure folder*** 
  - ***README.MD*** (This file)

***helpers*** is a special folder which contains bash scripts that can be run remotely on the EC2 machines to provision them after creation. 

The ***modules*** folder contains reusable modules (e.g. ec2, network etc.) which are called by the main terraform project declarations.

Each of the ***infrastructure folders*** (e.g. ubuntu), contain the terraform declaration files. There can be multiple ***xxxxx.tf*** files in each of these folders. All files in a folder are processed when terraform is run. 

It is conventional to have outputs and variables in separate files from the main declaration file. Reusable declarations can be isolated as modules and called from the main files. All the declaration files in this project have been designed to be flexible and allow several different machine configurations to be created by just changing the variables in the ***xxxxx-vars.tf*** files.

### Creating infrastructure
To create a machines or set of machines, switch to one of the infrastructure folders (e.g. ubuntu) and from a ***bash*** command line run ***terraform init***, followed by ***terraform apply***. The ***init*** command will make sure the required plug-ins are installed and properly setup. The ***apply*** command will analyze the terraform files in the folder and if no errors show up, will provide a plan for creating the infrastructure and request permission to create the infrastructure. There are ways to avoid this manual step, but initially it might be better to have this step so you can understand what infrastructure is going to be created. Once permission is granted, Terraform creates the infrastructure (e.g. EC2 machines, VPCs etc.) and will indicate the results when completed. 

### Taking down infrastructure
In order to remove the created infrastructure, you should type ***terraform destroy*** from within the same project folder. This command will analyze the "state" and then prompt the user for permission to execute. When you provide permission by typing "yes" at the prompt, Terraform will destroy all the created infrastructure. You can manually verify this from the AWS console if you want to. 

NOTE: Terraform stores its "state" information locally in the same folder. The enterprise edition has a more advanced central storage method for the state and can be used well in production and with a team of developers. This central approach is not in scope for this project.    

## <a name="tii"></a>*Terraform installation instructions*
In order to use terraform as your infrastructure creator, it needs to be installed on the machine where you are going to run the terraform code.

Terraform is a single binary file and can easily be downloaded and installed. It is available for many operating systems. Check out details [here.](https://www.terraform.io/downloads.html)

If you are using a local 64-bit (x86) Linux machine (not ARM), you can do the following steps to install the 64-bit terraform binary to your machine. 

### Quick way to install terraform on a 64-bit Linux machine  
- Open a bash shell and switch to the ***helpers*** folder
- Check to see if ***setupterraform.sh*** can be executed by running ***ls -l***
  - If it is not, make it executable using the following command
```bash
ubuntu@ubuntu:~/iac/helpers$ chmod +x ./setupterraform.sh
```
- Run the ***setupterraform.sh*** bash script as shown below
```bash
ubuntu@ubuntu:~/iac/helpers$ ./setupterraform.sh
```
  - This script will check for a terraform binary in ***/usr/local/bin*** and if existing, removes it. Then it will figure out and grab the latest version of the 64-bit Linux version of ***terraform***. It will then unzip the file and copy the binary to the ***/usr/local/bin*** folder and run it to check the version. If all goes well, a message indicating success will get displayed along with the version of ***terraform*** installed. 
If you want to install terraform to a different location, then edit the ***setupterraform.sh*** file and change the following variable ***TERRAFORMINSTALLLOCATION*** to point to your new location. The code snippet below shows the variable location in the file. 

```bash
#!/bin/bash
# This script file sets up the 64 bit linux version of terraform on a linux machine.
# It checks for the latest version from the hashi corp download html page
# Then uses wget to download the zip file and unzips it. 
#
TERRAFORMINSTALLLOCATION="/usr/local/bin"
```
---
## <a name="awsclii"></a>*Quick way to install AWS CLI*
- Open a bash shell and switch to the ***helpers*** folder
- Check to see if ***setupawscli.sh*** can be executed by running ***ls -l***
  - If it is not, make it executable using the following command
```bash
ubuntu@ubuntu:~/iac/helpers$ chmod +x ./setupawscli.sh
```
- Run the ***setupawscli.sh*** bash script as shown below. Note that this script expects you to provide the AWS ***Access Key Id*** and the ***Secret Access Key*** on the command line as shown below. The the ***id*** is a 20 character ALL CAPS string and the ***secret*** is a 40 character alpha-numeric-specialcharacter string. Note that the values below are random and not real. 
```bash
ubuntu@ubuntu:~/iac/helpers$ ./setuptawscli.sh id=ABCDEFGHIJKLMNOPQRST secret=ABC76+sdasd98sd/8hsdgTHY/asdj86HGASGAHSY
```
  - This script will check if AWS CLI is installed on the local machine and if not, it will install it. It will use the supplied AWS ***Access Key Id*** and the ***Secret Access Key*** and configure the CLI. This will allow ***terraform*** to work correctly.  
---
## *Troubleshooting*

- When you run ***terraform apply***, if you get any errors like the following:

```bash
Error: Error applying plan:

1 error(s) occurred:

* module.myvpc.aws_vpc.vpc: 1 error(s) occurred:

* aws_vpc.vpc: Error creating VPC: UnauthorizedOperation: You are not authorized to perform this operation.
        status code: 403, request id: c80e8354-a890-4fff-96a7-55cf301c156d
```
Make sure you have setup your AWS credentials on the machine you are running ***terraform***. Check out details on how to do this [here.](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html)
Alternatively, if you'd like to try the quick way, check out the details [here.](#awsclii)
