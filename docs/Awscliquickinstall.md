# Infrastructure as Code - AWS CLI Quick Install

If you already have AWS CLI installed and configured properly, you don't need to do this step. Do this only if you have never installed AWS CLI on this machine.  

## Windows 10 Environment

If you want to install AWS CLI in a purely Windows environment, you can do it manually with the following steps. Make sure you have the ***Access Key Id*** and the ***Secret Access Key*** ready.

- Download the AWS CLI installer from [here](https://aws.amazon.com/cli/) and run it.
- Open a COMMAND PROMPT (cmd) or POWERSHELL and type ***aws --version*** to check it it is installed.

```cmd
C:\Users\myusername>aws --version
aws-cli/1.15.45 Python/2.7.9 Windows/8 botocore/1.10.45

C:\Users\myusername>
```

- Open a COMMAND PROMPT (cmd) or POWERSHELL and type ***aws configure***. It will prompt you to provide the following information. ***Access Key Id***, ***Secret Access Key***, ***region*** and ***output format***.

```cmd
C:\Users\myusername>aws configure
AWS Access Key ID [None]:
AWS Secret Access Key [None]:
Default region name [None]:
Default output format [None]:

C:\Users\myusername>
```

- To verify that the AWS CLI is working, type ***aws iam get-user***. It should display your default user information.

```cmd
C:\Users\myusername>aws iam get-user
{
    "User": {
        "UserName": "awsuser",
        "PasswordLastUsed": "2018-06-25T18:15:06Z",
        "CreateDate": "2016-08-14T00:59:12Z",
        "UserId": "ABCDEFGHIJKLMNOPQRST",
        "Path": "/",
        "Arn": "arn:aws:iam::0123456789012:user/awsuser"
    }
}

C:\Users\myusername>
```

- Your AWS CLI is setup for use by Terraform.

## Linux Environment (including Windows Subsystem for Linux - WSL or ubuntu on Windows)

- Open a bash shell and switch to the ***iac/helpers*** folder in the ***iac*** project
- Check to see if ***setupawscli.sh*** can be executed by running ***ls -l***
  - If it is not, make it executable using the following command

```bash
ubuntu@ubuntu:~/iac/helpers$ chmod +x ./setupawscli.sh
```

- Run the ***setupawscli.sh*** bash script as shown below. Note that this script expects you to provide the AWS ***Access Key Id*** and the ***Secret Access Key*** on the command line as shown below. The the ***id*** is a 20 character ALL CAPS string and the ***secret*** is a 40 character alpha-numeric-specialcharacter string. Note that the values below are random and not real.

```bash
ubuntu@ubuntu:~/iac/helpers$ ./setuptawscli.sh id=ABCDEFGHIJKLMNOPQRST secret=ABC76+sdasd98sd/8hsdgTHY/asdj86HGASGAHSY
```

- This script will check if AWS CLI is installed on the local machine and if not, it will install it. It will use the supplied AWS ***Access Key Id*** and the ***Secret Access Key*** and configure the CLI. With this setup complete you can use the AWS command line utility to perform any AWS actions or use Terrafrom to create AWS infrastructure.
