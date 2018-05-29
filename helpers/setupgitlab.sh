#!/bin/bash
# This is a script to install gitlab.
#
if [[ "${1:-}" == "" ]]; then POSTFIXSERVERDOMAIN="www.example.com"; else POSTFIXSERVERDOMAIN="$1"; fi 
POSTFIXMAILERTYPE="Internet Site"
sudo apt-get -y update
sudo apt-get install -y ca-certificates curl openssh-server 
# Set Server's domain name or IP address to configure how the system will send mail.
sudo echo "postfix postfix/mailname string $POSTFIXSERVERDOMAIN" | sudo debconf-set-selections
# Set mailer type as Internet Site.
sudo echo "postfix postfix/main_mailer_type string $POSTFIXMAILERTYPE" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y postfix
cd /tmp
curl -LO https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
sudo bash /tmp/script.deb.sh
# The script will set up your server to use the GitLab maintained repositories. 
# This lets you manage GitLab with the same package management tools you use for your other system packages. 
# Once this is complete, you can install the actual GitLab application with apt:
sudo apt-get install gitlab-ce
# Before you can use the application, however, you need to run an initial configuration command:
sudo gitlab-ctl reconfigure
# This will initialize GitLab using information it can find about your server. 
# This is a completely automated process, so you will not have to answer any prompts.
# View the current status of your active firewall by typing:
sudo ufw status
sudo ufw app list
sudo ufw allow OpenSSH
sudo ufw allow http
sudo ufw enable <<< "y"

echo -e "Manual steps to complete gitlab install"
echo -e "Go to http://gitlab_domain or http://<IPAddress> to the gitlab EC2> to run gitlab"
echo -e "Provide admin user and password. Click on change your password."
echo -e "Login with admin user/pwd"
echo -e "Update profile settings by providing your name/email for admin user."
echo -e "Create and add your ssh key public key using ssh-keygen" 
echo -e "Disable signups. (manually create accounts) Since this is just a test env." 
echo =e "For more details follow the steps provided here https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-gitlab-on-ubuntu-16-04"