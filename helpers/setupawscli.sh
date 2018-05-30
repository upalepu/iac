#!/bin/bash
# This script file sets up the aws command line interface awscli. 
# First it checks to see if awscli is installed, if so it checks to see if credentials are setup.
#
function finish() { # finish. This gets called when program exits (whether it is with error or normal exit)
    echo -e ""
} 
trap finish EXIT

AWS_CFG_DIR="$HOME/.aws"
AWS_CFG_FILE="$AWS_CFG_DIR/config"
AWS_CREDENTIALS_FILE="$AWS_CFG_DIR/credentials"
SCRIPTNAME=${BASH_SOURCE[0]##*/}	# Strip off the path & get scriptname.

if (($# < 2)); then 
    echo -e "Usage:"
    echo -e "\t$SCRIPTNAME id=<AWS Access Key Id> secret=<AWS Secret Access Key>"
    exit 1
fi
AWS_ACCESS_KEY_ID=${1#*=}
if ((${#AWS_ACCESS_KEY_ID} != 20)); then 
    echo -e "[$1] does not appear to be a valid AWS Access Key Id"
    echo -e "Valid id will look like this -> ABCDEFGHIJKLMNOPQRST"
    exit 1 
fi

AWS_SECRET_ACCESS_KEY=${2#*=}
if ((${#AWS_SECRET_ACCESS_KEY} != 40)); then 
    echo -e "[$2] does not appear to be a valid AWS Secret Access Key"
    echo -e "Valid key will look like this -> ABC76+sdasd98sd/8hsdgTHY/asdj86HGASGAHSY"
    exit 1 
fi

AWSINSTALLED=$(which aws)
PYTHON3INSTALLED=$(which python3)
PIP3INSTALLED=$(which pip3)
if [[ "$AWSINSTALLED" = "" ]]; then
    echo -e "AWS Command Line Interface is not installed. Checking dependencies and installing ..."
    if [[ "$PIP3INSTALLED" == "" ]]; then 
        sudo apt-get update -y &>/dev/null
        if [[ "$PYTHON3INSTALLED" == "" ]]; then
            sudo apt-get install -y python3 &>/dev/null
        fi
        sudo apt-get install -y python3-pip &>/dev/null
    fi
    pip3 install awscli --upgrade --user &>/dev/null
fi
echo -e "AWS Command Line Interface is installed."
echo -e "Creating AWS CLI configuration ..."

if [[ ! -d "$AWS_CFG_DIR" ]]; then mkdir "$AWS_CFG_DIR"; fi
if [[ -e "$AWS_CFG_FILE" ]]; then mv "$AWS_CFG_FILE"  "$AWS_CFG_FILE-$(date +%m%d%y%H%M%S%N)"; fi
if [[ -e "$AWS_CREDENTIALS_FILE" ]]; then mv "$AWS_CREDENTIALS_FILE"  "$AWS_CREDENTIALS_FILE-$(date +%m%d%y%H%M%S%N)"; fi

echo -e "[default]" >> "$AWS_CFG_FILE"
echo -e "output = json" >> "$AWS_CFG_FILE"
echo -e "region = us-east-1" >> "$AWS_CFG_FILE"

echo -e "[default]" >> "$AWS_CREDENTIALS_FILE"
echo -e "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> "$AWS_CREDENTIALS_FILE"
echo -e "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> "$AWS_CREDENTIALS_FILE"

echo -e "AWS CLI configuration completed!"
