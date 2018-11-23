# Infrastructure as Code - Troubleshooting

When you run ***terraform*** or ***terraform init***, if you get any errors like the following:

```bash
ubuntu@ubuntu:~/iac/ubuntu$terraform
terraform: command not found
```

Make sure you have ***terraform*** installed on the local machine. Check out details on how to do this [here.](#tii)

---

When you run ***terraform apply***, if you get the following error:

```bash
Error: Error applying plan:
1 error(s) occurred:
* module.myvpc.aws_vpc.vpc: 1 error(s) occurred:
* aws_vpc.vpc: Error creating VPC: UnauthorizedOperation: You are not authorized to perform this operation.
        status code: 403, request id: c80e8354-a890-4fff-96a7-55cf301c156d
```

Make sure you have setup your AWS credentials on the machine you are running ***terraform***. Check out details on how to do this [here.](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html)
Alternatively, if you'd like to try the quick way, check out the details [here.](#awsclii)

---

When you run ***terraform apply***, if you get the following error:

```bash
Error: module.ubuntu.null_resource.provisioning: 1 error(s) occurred:
* module.ubuntu.null_resource.provisioning: file: open : no such file or directory in:
${file(var.private_key_path)}
```

Make sure you have provided the path to the private and public key files in the ***xxxxx-vars.tf*** file.

---

When you run ***terraform apply***, if you get the following error:

```bash
module.ubuntu.null_resource.provisioning: Provisioning with 'remote-exec'...
module.ubuntu.null_resource.provisioning (remote-exec): Connecting to remote host via SSH...
module.ubuntu.null_resource.provisioning (remote-exec):   Host: 34.200.239.71
module.ubuntu.null_resource.provisioning (remote-exec):   User: ubuntu
module.ubuntu.null_resource.provisioning (remote-exec):   Password: false
module.ubuntu.null_resource.provisioning (remote-exec):   Private key: true
module.ubuntu.null_resource.provisioning (remote-exec):   SSH Agent: false
module.ubuntu.null_resource.provisioning (remote-exec):   Checking Host Key: false
module.ubuntu.null_resource.provisioning: Still creating... (10s elapsed)
module.ubuntu.null_resource.provisioning (remote-exec): Connecting to remote host via SSH...
module.ubuntu.null_resource.provisioning (remote-exec):   Host: 34.200.239.71
module.ubuntu.null_resource.provisioning (remote-exec):   User: ubuntu
module.ubuntu.null_resource.provisioning (remote-exec):   Password: false
module.ubuntu.null_resource.provisioning (remote-exec):   Private key: true
module.ubuntu.null_resource.provisioning (remote-exec):   SSH Agent: false
module.ubuntu.null_resource.provisioning (remote-exec):   Checking Host Key: false
..
..
```

If the above status keeps repeating itself for several minutes, it should eventually exit after about 5 minutes. This happens when the SSH credentials are not provided or not correct in the
***xxxxx-vars.tf*** file. Make sure you include the correct information for all of the following variables: ***public_key_path***, ***private_key_path***, and ***key_name***. Any one of these missing or incorrect will result in the above issue.

---

When you run ***terraform apply***, if you get the following error:

```bash
Error: Error refreshing state: 1 error(s) occurred:

* provider.aws: No valid credential sources found for AWS Provider.
        Please see https://terraform.io/docs/providers/aws/index.html for more information on
        providing credentials for the AWS Provider
```

This happens if you tried to run the kubernetes cluster creation before setting up your aws credentials on the machine. To address this you can change to the ***iac/helpers*** directory and run the ***setupawscli.sh*** program. It requires two command line params, your AWS Access Id and secret access key.

---

When ***terraform apply or terraform init*** is run and you get the following error:

```bash
ubuntu@ubuntu:~/iac/iacec2$ terraform apply
* module.iacec2.aws_instance.ec2: lookup: lookup failed to find '16-us-west-2' in: ${lookup(var.amis,local.ami_key)}
```

This usually happens if there is no AMI available for the specified region or specified version. Check the ec2.tf file in the modules folder and add an appropriate AMI from AWS. Currently AMIs for us-east-1, us-east-2, us-west-1 and us-west-2 are included.

---
