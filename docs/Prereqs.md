# Infrastructure as Code - Pre-requisites

1. You will need an AWS Account. If you don't have an account, sign up for free [here.](https://aws.amazon.com/free/)
2. You will also need your AWS ***Access Key Id*** and ***Secret Access Key***. Check out details on how to get these [here.](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html) If you don't have these or lost them you can recreate these. Check out details [here.](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)
3. You will need the AWS Commandline Interface (CLI) installed on your local machine. For a quick way to install the AWS CLI on your local machine, follow the instructions [here.](./Awscliquickinstall.md)
4. You will need ***Terraform*** installed on your local machine. All the terraform code in this project has been tested with ***v0.11.x***. Check out details [here.](./Terraforminstall.md). Although, there are no known issues with running this code with the new ***v0.12.x***, there are a lot of steps to be followed in order to get the code to be properly upgraded. You should check out the information [here](https://www.terraform.io/upgrade-guides/0-12.html) before using this code on ***v0.12.x***.
5. Your favorite IDE or code editor (e.g. vscode, notepad++, vi etc.)
