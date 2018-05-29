#!/bin/bash
# This script file sets up the 64 bit linux version of terraform on a linux machine.
# It checks for the latest version from the hashi corp download html page
# Then uses wget to download the zip file and unzips it. 
#
TERRAFORMINSTALLLOCATION="/usr/local/bin"
if [[ -e "$TERRAFORMINSTALLLOCATION" ]]; then
    echo -e "Removing existing terraform ..."
    sudo rm $TERRAFORMINSTALLLOCATION/terraform &>/dev/null
fi 
echo -e "Checking for latest version of 64-bit Linux Terraform ..."
wget https://releases.hashicorp.com/terraform &>/dev/null
if (($?)); then echo -e "Could not figure out latest version of terraform. Install it manually!"; exit 1; fi
cat terraform | grep -Eo "/[0-9]*\.[0-9]*\.[0-9]*" | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*" > tmp
read -e LATESTTERRAFORMVERSION < tmp
echo -e "Latest Terraform version is [$LATESTTERRAFORMVERSION]"
echo -e "Cleaning up tmp files ..."
if [[ -e "./terraform" ]]; then rm ./terraform &>/dev/null; fi
if [[ -e "./tmp" ]]; then rm ./tmp > /dev/null; fi
TERRAFORMZIP="terraform_""$LATESTTERRAFORMVERSION""_linux_amd64.zip"
echo -e "Downloading latest terraform file [$TERRAFORMZIP] ..." 
wget https://releases.hashicorp.com/terraform/$LATESTTERRAFORMVERSION/$TERRAFORMZIP &>/dev/null
if (($?)); then echo -e "Could not download [$TERRAFORMZIP]. Install it manually!"; exit 1; fi
unzip ./$TERRAFORMZIP &>/dev/null
sudo mv terraform $TERRAFORMINSTALLLOCATION &>/dev/null
echo -e "Checking if [$TERRAFORMINSTALLLOCATION] is in the PATH ..."
env | grep -Eoc "$TERRAFORMINSTALLLOCATION"
if ((!$?)); then 
    echo -e "Could not find [$TERRAFORMINSTALLLOCATION] in the PATH. Adding ..."
    export PATH="$TERRAFORMINSTALLOCATION:$PATH"; 
fi

echo -e "Cleaning up terraform zip file [$TERRAFORMZIP] ..."
if [[ -e "./$TERRAFORMZIP" ]]; then rm ./$TERRAFORMZIP &>/dev/null; fi
terraform --version
if (($?)); then 
    echo -e "Terraform installation didn't complete! Install it manually!"
else 
    echo -e "Terraform [$TERRAFORMZIP] installed successfully!"
fi
