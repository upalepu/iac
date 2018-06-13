# Infrastructure as Code - AWS CLI Quick Install
If you already have AWS CLI installed and configured properly, you don't need to do this step. Do this only if you have never installed AWS CLI on this machine.  
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
