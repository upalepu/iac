#!/bin/bash
# This script file sets up the 64 bit linux version of terraform on a linux machine.
# It checks for the latest version from the hashi corp download html page
# Then uses wget to download the zip file and unzips it. 
#
TERRAFORMINSTALLLOCATION="/usr/local/bin"

function finish() { # finish. This gets called when program exits (whether it is with error or normal exit)
    echo -e "Cleaning up terraform zip file [$TERRAFORMZIP] ..."
    if [[ -e "./$TERRAFORMZIP" ]]; then rm ./$TERRAFORMZIP &>/dev/null; fi
} 
trap finish EXIT

if [[ -e "$TERRAFORMINSTALLLOCATION/terraform" ]]; then
    echo -e "\nRemoving existing terraform ..."
    sudo rm $TERRAFORMINSTALLLOCATION/terraform &>/dev/null
fi 
echo -e "\nChecking for latest version of 64-bit Linux Terraform ..."
wget https://releases.hashicorp.com/terraform &>/dev/null
if (($?)); then echo -e "Could not figure out latest version of terraform. Install it manually!"; exit 1; fi
cat terraform | grep -Eo "/[0-9]*\.[0-9]*\.[0-9]*" | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*" > tmp
read -e LATESTTERRAFORMVERSION < tmp
echo -e "Cleaning up tmp files ..."
if [[ -e "./terraform" ]]; then rm ./terraform &>/dev/null; fi
if [[ -e "./tmp" ]]; then rm ./tmp > /dev/null; fi
echo -e "Latest Terraform version is [$LATESTTERRAFORMVERSION]"
TERRAFORMZIP="terraform_""$LATESTTERRAFORMVERSION""_linux_amd64.zip"
echo -e "\nDownloading latest terraform file [$TERRAFORMZIP] ..." 
wget https://releases.hashicorp.com/terraform/$LATESTTERRAFORMVERSION/$TERRAFORMZIP &>/dev/null
if (($?)); then echo -e "Could not download [$TERRAFORMZIP]. Install it manually!"; exit 1; fi
isunzip=$(which unzip)
if [[ "$isunzip" == "" ]]; then 
    echo -e "unzip not found. Installing ..."
    sudo apt-get install -y zip unzip &>/dev/null
fi
unzip ./$TERRAFORMZIP &>/dev/null
if [[ ! -e "terraform" ]]; then echo -e "unzip failed to unzip terraform"; fi
if [[ ! -d "$TERRAFORMINSTALLLOCATION" ]]; then sudo mkdir "$TERRAFORMINSTALLLOCATION"; fi
sudo mv ./terraform $TERRAFORMINSTALLLOCATION
if (($?)); then 
    echo -e "Failed to move [terraform] to [$TERRAFORMINSTALLLOCATION.]. Stopping operation."
    exit 1
else
    echo -e "Moved [terraform] to [$TERRAFORMINSTALLLOCATION.]"
fi 
echo -e "\nChecking if [$TERRAFORMINSTALLLOCATION] is in the PATH ..."
INPATH=$(env | grep -Eoc "$TERRAFORMINSTALLLOCATION")
if ((!$INPATH)); then 
    echo -e "Could not find [$TERRAFORMINSTALLLOCATION] in the PATH. Adding ..."
    if [[ ! -e ~/.bashrc ]]; then touch ~/.bashrc; fi
    echo -e "export export PATH=$TERRAFORMINSTALLOCATION:\$PATH" >> ~/.bashrc   # Sets it for future
    echo -e "Path will work the next time you log in to this machine."
else
    echo -e "Found [$TERRAFORMINSTALLLOCATION] in the PATH!"
fi
$TERRAFORMINSTALLLOCATION/terraform --version
if (($?)); then 
    echo -e "Terraform installation didn't complete! Install it manually!"
else 
    echo -e "$($TERRAFORMINSTALLLOCATION/terraform --version) installed successfully from [$TERRAFORMZIP]!"
fi
