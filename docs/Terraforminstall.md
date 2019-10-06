# Infrastructure as Code - Terraform installation

In order to use terraform as your infrastructure creator, it needs to be installed on the machine where you are going to run the terraform code.

Terraform is a single binary file and can easily be downloaded and installed. It is available for many operating systems. Check out details [here.](https://www.terraform.io/downloads.html)

NOTE: This code has been tested with ***v0.11.x*** and not the latest ***v0.12.x***. Make sure you download the older version. Although it is likely that this code will work on the latest version of ***Terraform***, there are several steps to follow, so if you are a ***Terraform*** novice, I would strongly recommend sticking with ***v0.11.x***. If you know what you're doing, by all means go ahead.

For more information on upgrading existing code to ***v0.12.x***, check out the instructions [here.](https://www.terraform.io/upgrade-guides/0-12.html)  

## Quick way to install Terraform on a 64-bit Linux machine  

If you are using a local 64-bit (x86) Linux machine (not ARM), you can do the following steps to install the 64-bit Terraform binary to your machine.

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
- If you want to install terraform to a different location, then edit the ***setupterraform.sh*** file and change the following variable ***TERRAFORMINSTALLLOCATION*** to point to your new location. The code snippet below shows the variable location in the file.

```bash
#!/bin/bash
# This script file sets up the 64 bit linux version of terraform on a linux machine.
# It checks for the latest version from the hashi corp download html page
# Then uses wget to download the zip file and unzips it.
#
TERRAFORMINSTALLLOCATION="/usr/local/bin"
```

## Install Terraform on a Windows 10 machine  

If you wish to install terraform on a Windows 10 machine, you can do the following steps.

- Download the appropriate Terraform zip file from [here](https://www.terraform.io/downloads.html) and extract the terraform.exe file to an appropriate directory. (e.g. C:\HashiCorp)
- Add this directory to your Windows system Path Environment variable.
- Open a COMMAND PROMPT (cmd) or POWERSHELL and type ***terraform version*** to check that it is installed.

```cmd
C:\Users\myusername>terraform version
Terraform v0.11.7

C:\Users\myusername>
```

- Thats it. Terraform is installed and ready to be used on your Windows machine.
