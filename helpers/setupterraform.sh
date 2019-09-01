#!/bin/bash
# This script file sets up the 64 bit linux version of terraform on a linux machine.
# It checks for the latest version from the hashi corp download html page
# Then uses wget to download the zip file and unzips it. 
#
which wget &>/dev/null; if (($?)); then echo -e "wget is needed to run this script. Install wget and try again."; exit 1; fi
env | grep -E "OS=" &>/dev/null # Check if we're running bash inside windows 
if (($?)); then 
    TERRAFORMINSTALLLOCATION="/usr/local/bin"; PLATFORM=linux; TERRAFORM=terraform; SUDOCMD=sudo
else 
    TERRAFORMINSTALLLOCATION="$HOME/.local/bin"; PLATFORM=windows; TERRAFORM=terraform.exe
fi

function finish() { # finish. This gets called when program exits (whether it is with error or normal exit)
    echo -e "Cleaning up terraform zip file [$TERRAFORMZIP] ..."
    if [[ -f "./$TERRAFORMZIP" ]]; then rm ./$TERRAFORMZIP &>/dev/null; fi
} 
trap finish EXIT

if [[ -f "$TERRAFORMINSTALLLOCATION/$TERRAFORM" ]]; then
    echo -e "\nRemoving existing terraform ..."
    $SUDOCMD rm $TERRAFORMINSTALLLOCATION/$TERRAFORM &>/dev/null
fi 
echo -e "\nChecking for latest version of 64-bit $PLATFORM Terraform ..."
wget https://releases.hashicorp.com/terraform &>/dev/null
if (($?)); then echo -e "Could not figure out latest version of terraform. Install it manually!"; exit 1; fi
cat terraform | grep -Eo "/[0-9]*\.[0-9]*\.[0-9]*" | grep -Eo "[0-9]*\.[0-9]*\.[0-9]*" > tmp
SUCCESS=0
while read -r LATESTTERRAFORMVERSION; do
    TERRAFORMZIP="terraform_""$LATESTTERRAFORMVERSION""_""$PLATFORM""_amd64.zip"
    wget https://releases.hashicorp.com/terraform/$LATESTTERRAFORMVERSION/$TERRAFORMZIP &>/dev/null
    if (($?)); then continue; else SUCCESS=1; break; fi 
done < tmp 
if ((!$SUCCESS)); then echo -e "Could not download [$TERRAFORMZIP]. Try to install manually."; exit 1; fi 
echo -e "Latest Terraform version is [$LATESTTERRAFORMVERSION]"
echo -e "Cleaning up tmp files ..."
if [[ -e "./terraform" ]]; then rm ./terraform &>/dev/null; fi
if [[ -e "./tmp" ]]; then rm ./tmp > /dev/null; fi
isunzip=$(which unzip)
if [[ "$isunzip" == "" ]]; then 
    echo -e "unzip not found. Installing ..."
    $SUDOCMD apt-get install -y zip unzip &>/dev/null
fi
unzip ./$TERRAFORMZIP &>/dev/null
if [[ ! -e "terraform" ]]; then echo -e "unzip failed to unzip terraform"; fi
if [[ ! -d "$TERRAFORMINSTALLLOCATION" ]]; then $SUDOCMD mkdir "$TERRAFORMINSTALLLOCATION"; fi
$SUDOCMD mv ./terraform $TERRAFORMINSTALLLOCATION
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
    if [[ ! -f $HOME/.bashrc ]]; then touch $HOME/.bashrc; fi
    echo -e "export PATH=$TERRAFORMINSTALLOCATION:\$PATH" >> $HOME/.bashrc   # Sets it for future
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
