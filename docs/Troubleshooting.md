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
Error: Error applying plan:
1 error(s) occurred:
* aws_iam_user.user: 1 error(s) occurred:
* aws_iam_user.user: Error creating IAM User kops: EntityAlreadyExists: User with name kops already exists.
        status code: 409, request id: 0ecebb16-6631-11e8-af7e-cbdd9950e9ec

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
```

This happens if you already have a user account with the name kops in your AWS account. Go to the AWS console and delete that account manually and then try again.

---

When you run ***terraform apply***, if you get the following error:

```bash
data.aws_route53_zone.hz: Refreshing state...
Error: Error refreshing state: 1 error(s) occurred:
* data.aws_route53_zone.hz: 1 error(s) occurred:
* data.aws_route53_zone.hz: data.aws_route53_zone.hz: no matching Route53Zone found
```

This happens if you have not provided a valid domain name in the ***kubernetes-vars.tf*** file. Check the name of the hosted zone in your AWS Route53 console and set it in the  ***parm_domain*** key of the ***k8scfg*** variable.

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

When ***kops create cluster*** is run and you get the following error:

```bash
State Store: Required value: Please set the --state flag or export KOPS_STATE_STORE.
A valid value follows the format s3://<bucket>.
A s3 bucket is required to store cluster state information.
```

This happens if kops cannot figure out the s3 bucket name where it needs to store the state. Make sure you specify the s3 bucket value either on the command line or export KOPS_STATE_STORE.

---

When ***kops create cluster*** is run and you get the following error:

```bash
ubuntu@ubuntu:~/iac/kubernetes$ kops create cluster --zones us-east-1a --state s3://demo-kubernetes-state kubernetes.example.com
I0610 23:25:27.032808    8794 create_cluster.go:472] Inferred --cloud=aws from zone "us-east-1a"
I0610 23:25:27.126466    8794 subnets.go:184] Assigned CIDR 172.20.32.0/19 to subnet us-east-1a
Previewing changes that will be made:
SSH public key must be specified when running with AWS (create with `kops create secret --name kubernetes.palepuweb.org sshpublickey admin -i ~/.ssh/id_rsa.pub`)
```

This usually happens if there is no ***id_rsa*** key pair in the ~/.ssh directory. use the following command to fix this.

```bash
ubuntu@ubuntu:~$ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
```

---

When ***terraform init -backend-config=tfs3b.cfg*** is run and you get a prompt for S3, like below ...

```bash
ubuntu@ip-10-0-1-42:~/iac/kubernetes$ terraform init

Initializing the backend...
Backend configuration changed!

Terraform has detected that the configuration specified for the backend
has changed. Terraform will now check for existing state in the backends.

bucket
  The name of the S3 bucket

  Enter a value:
```

This happens if there is no ***tfs3b.cfg*** file or if the data in it is not valid. You can manually add the following information to the ***tfs3b.cfg*** file and try again. If you don't know what your AWS Account Alias is - its what you type in when you first login to the AWS console application. Alternatively, go back to the ***iacec2*** project and try to create the EC2 machine again.

```bash
bucket = "<your aws acct alias>-demo-iacec2-terraform-state"
key = "kubernetes/terraform.tfstate"
region = "us-east-1"
```

---
