
# Infrastructure as Code - Folder structure and Terraform usage overview
Terraform uses a declarative language to setup and configure infrastructure. Plugins for various providers (e.g. AWS, GCP, Azure etc.) are available which enable you to create infrastructure configurations which are agnostic to the specific provider. With well designed declaration files, Terraform enables highly scalable infrastructures. 

### Folder structure
The folder structure for this project is designed for modularity and is as follows:
- ***iac*** (root folder)
  - ***docs*** (contains the documentation for various sub-projects in this project)
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

## *Terraform installation instructions*
For details on installing terraform click [here.](./Terraforminstall.md)
