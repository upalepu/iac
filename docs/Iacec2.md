# Infrastructure as Code - Creating an (iac) Dev/Test EC2 machine on AWS

The purpose of this project is to have an AWS EC2 machine automatically created with everything on it to explore infrastructure as code (iac) using Terraform. In addition this machine can also be used to automatically setup AWS and create a Kubernetes cluster.

If you're wondering why do I need a separate AWS EC2 machine to run my terraform configurations, why not use my local machine? The answer is simple, if you know what you're doing and you're an advanced user of Terraform, AWS, Kubernetes etc., you can do everything from your local machine. If you're still learning, you're safer with a separate environment where your experiments don't end up creating problems with your development machine.

<div class="twocol"></div>

Here's how the system architecture looks like. For simplicity, only port 80 and 443 are shown here for http(s) connections. You can setup the VPC for allowing any kind of port access. SSH can also be limited only to your IP address for additional security, but you will have to set that up yourself. The iacec2 machine is loaded with Ubuntu, the iac project, terraform, aws commandline and an S3 bucket for storing Terraform state remotely. In addition the machine is configured to access AWS using the kops user account. This account will be used by Kubernetes, but can also serve the purpose of accessing AWS and experimenting with AWS command line utilities.

![AWS EC2 Architecture (iacec2)](./iacec2.png "AWS EC2 Architecture (iacec2)")

<div class="onecol"></div>

## Pre-requisites

Make sure you have all the pre-requisites needed to successfully run this project by clicking [here.](./Prereqs.md)

## Steps to follow  

There are three sets of steps to follow: [Configure](#cfg), [Create](#create) and [Destroy.](#destroy)

### <a name="cfg"></a>Configure

- After making sure you have met all the pre-requisites, switch to the ***iac/iacec2*** folder in the ***iac*** project and use your favorite editor create a new ***terraform.tfvars*** file. It it already exists, edit it.
- In this file add the following information. You will need the ***public_key_path, private_key_path & key_name*** of your AWS account. NOTE: The ***public_key_path*** and ***private_key_path*** are AWS the credential key pair for SSH access. The ***key_name*** is the associated key used by AWS.

```bash
public_key_path = "~/.ssh/my_aws_public_key.pub"
private_key_path = "~/.ssh/my_aws_private_key.pem"
key_name = "my_aws_key"
```

NOTE: If you wish to use either the ***kubernetes*** or ***k8sgossip*** project, you will need to make sure you set the *parm_k8sproj* variable in the *k8scfg* map. By default this variable is set to ***k8sgossip***, so you don't have to do anything here. This means, when you login to the ***iacec2*** machine, you can use the ***k8sgossip*** project to create your Kubernetes cluster. This is the correct choice if you do not have an external domain configured either in AWS or by a 3rd party DNS service. See [Domains](./Domains.md) for more details on this. If you have an external domain name in AWS Route53 or with a 3rd party DNS service like GoDaddy and you want to create your Kubernete cluster as a subdomain under that domain, then you can change the *parm_k8sproj* variable as shown below.  

- To change the *parm_k8sproj* variable to *kubernetes*, simply add the following to the ***terraform.tfvars*** file created earlier.

```bash
k8scfg = {
  parm_k8sproj = "kubernetes"
}
```

- Save your configuration and go to [Create.](#create)

### <a name="create"></a>Create

The following steps will show you how to create an iacec2 EC2 machine using Terraform. Make sure you have configured Terraform by following the steps in the [Configure](#cfg) section.

- At your bash prompt, run the ***terraform init*** command. The plugins will be installed and the system will be checked for proper dependencies. If there are no errors you will see output similar to the following. The output below has been edited for brevity. If there are errors click [here](./Troubleshooting.md) to troubleshoot the problem.

```bash
ubuntu@ubuntu:~/iac/iacec2$ terraform init
Initializing modules...
.
.
.
If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

- Now run the ***terraform apply*** command. Type ***yes*** when prompted by the system after you have reviewed the items to be created. If you don't type ***yes***, the command will be cancelled. There will be several items created. This includes the items needed for the VPC and the EC2 machine. In addition the terraform and aws command line utility are installed and configured. Terraform will also create an S3 bucket to store it's state remotely. This ensures that if the EC2 machine goes down, Terraform can easily revert back the state from S3 and continue managing the infrastructure properly.

```bash
ubuntu@ubuntu:~/iac/iacec2$ terraform apply
```

The result as indicated below will be output showing the details of the EC2 machine created. You can access the machine using SSH by either specifying the IP address or the Amazon EC2 name which looks like this - ***ec2-35-168-58-160.compute-1.amazonaws.com***.

```bash
data.aws_iam_account_alias.current: Refreshing state...
data.aws_caller_identity.current: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_iam_access_key.cak
      id:                                        <computed>
      encrypted_secret:                          <computed>
      key_fingerprint:                           <computed>
      secret:                                    <computed>
      ses_smtp_password:                         <computed>
      status:                                    <computed>
      user:                                      "kops"
.
.
.
Apply complete! Resources: 24 added, 0 changed, 0 destroyed.

Outputs:

iacec2_info = {
    .
    .
  access_key_user = kops
  ec2_info = map[additional_volumes.sizes:[] public_dns_ip:map[ec2-35-153-213-131.compute-1.amazonaws.com:35.153.213.131] root_volume:[[map[volume_size:15 delete_on_termination:1 volume_id:vol-04a0dc5a1d4f01567 volume_type:gp2 iops:100]]] additional_volumes.device_names:[] additional_volumes.types:[]]
  ec2_ip = [35.153.213.131]
  group_arn = arn:aws:iam::187601144312:group/kopsgroup
  group_name = kopsgroup
  group_uid = AGPAJFSHMBCM3UBK4VLCO
  network_info = map[internal_cidr_block:10.0.0.0/16 internet_gateway:igw-030ee51a91f22759e internet_access_cidr_block:0.0.0.0/0 subnet:subnet-04fe82161e77e47f6 subnet_cidr_block:10.0.1.0/24 security_group:sg-0cdb897d0788f83fe vpc:vpc-05bc01b84214349d0]
  s3bucket_arn = arn:aws:s3:::palepuweb-demo-iacec2-terraform-state
  s3bucket_id = palepuweb-demo-iacec2-terraform-state
  s3bucket_region = us-east-1
  user_arn = arn:aws:iam::187601144312:user/kops
  user_name = kops
  user_uid = AIDAIR3SJ2K6NF5VNTHRM
}
ubuntu@ubuntu:~/iac/iacec2$
}
```

Your AWS EC2 iacec2 machine is now created and ready for use. To verify that the machine is available, SSH into the machine from a bash command prompt and verify that the machine is up and running. You can now go on to do other Terraform related projects or any other projects you wish to. When you are done and want to destroy this machine and its related infrastructure, go to the [Destroy](#destroy) section and follow the steps listed there.

NOTE: If you are interested in creating a Kubernetes cluster using the ***k8sgossip*** or ***kubernetes*** projects, make sure you read the information in the [Configure](#cfg) section carefully to know which project to use. This is because for an internal domain, the VPC id is needed and the ***iacec2*** project provides that information in a file called *vpc* if the project is set to ***k8sgossip***.

### <a name="destroy"></a>Destroy

Now that you are ready to destroy your newly created infrastructure, follow the steps below.

- Change to the ***iac/iacec2*** folder at your bash prompt and type ***terraform destroy***.

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform apply
```

When prompted, type ***yes*** after making sure that the number of items being destroyed matches the number of items created. You will see the result of the command similar to what is shown below. For brevity, most of the output is not shown.

```bash
ubuntu@ubuntu:~/iac/ubuntu$ terraform destroy
aws_vpc.vpc: Refreshing state... (ID: vpc-04d46999e8a521fb3)
aws_security_group.security_group: Refreshing state... (ID: sg-03bdd9f4f79c237a1)
.
.
.
.
module.myvpc.aws_vpc.vpc: Destroying... (ID: vpc-04d46999e8a521fb3)
module.myvpc.aws_vpc.vpc: Destruction complete after 1s

Destroy complete! Resources: 24 destroyed.
ubuntu@ubuntu:~/iac/ubuntu$
```

Your AWS EC2 infrastructure is completely destroyed. To verify that the machine is no longer available, try to SSH into the machine from a bash command prompt. You should get a timeout. Try and access the machine from your browser, using both the IP address and the Amazon EC2 address. You should get an error. You can also go to AWS console and check out the EC2 Service and also the VPC service. Since this project also created a kops user account and a kops group, check out if those items have been removed as well. And don't forget to check if the S3 bucket to store Terraform state has been destroyed as well.

## Summary

Creating an ***iacec2*** EC2 machine was as simple as specifying a few configuration parameters in the ***terraform.tfvars*** file and running a couple of Terraform commands. In that machine you had a safe and simple environment to experiment with Terraform. If you tried the Kubernetes project you also have experiened the power of creating an entire Kubernetes cluster and destroy it all. If you haven't yet tried the [kubernetes](./Kubernetes.md) project, go back and re-run this project to create the iacec2 machine and then go to the kubernetes project and create a Kubernete cluster. Note that Kubernetes will install at a minimum 3 machines and will also setup many other AWS items like a hosted zone and a subdomain etc. Several of these services will cost money, so make sure you destroy the items after you're done experimenting, so you don't incur too much cost.

If you want to learn about Terraform in more detail go to the [source](http://www.terraform.io) and learn more.  

<style>
.twocol ~ * { width: 50%; float: left; box-sizing: border-box; padding-left: 1rem; }
.onecol ~ * { clear: both; width: 100%; padding-left: 0; }
</style>
