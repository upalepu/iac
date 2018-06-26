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
AWS_REGION="us-east-1"
AWS_OUTPUT="json"
SCRIPTNAME=${BASH_SOURCE[0]##*/}	# Strip off the path & get scriptname.

if (($# < 2)); then 
    echo -e "Usage:"
    echo -e "\t$SCRIPTNAME id=<AWS Access Key Id> secret=<AWS Secret Access Key>"
    echo -e "Valid id will look like this -> ABCDEFGHIJKLMNOPQRST"
    echo -e "Valid secret will look like this -> ABC76+sdasd98sd/8hsdgTHY/asdj86HGASGAHSY"
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
    echo -e "Valid secret will look like this -> ABC76+sdasd98sd/8hsdgTHY/asdj86HGASGAHSY"
    exit 1 
fi
# in Windows bash, which returns a big string instead of nothing if it doesn't find the cmd. So we redirect err to /dev/null. 
# This works for both envs. grep -Eoc returns 1 if found. 0 if not. 
AWSINSTALLED=$(which aws 2>/dev/null | grep -Eoc aws)
if [[ ! -z ${OS:-} ]]; then	    # Will be non-zero if running bash in windows 
    if ((!$AWSINSTALLED)); then
        echo -e "AWS Command Line Interface is not installed."
        echo -e "Please install it manually from here - https://aws.amazon.com/cli/"
        echo -e "Once you're done with that, you can run this program again to configure AWS CLI"
        exit 1
    fi
else 
    # Only do this for regular unix envs. 
    PYTHON3INSTALLED=$(which python3 2>/dev/null | grep -Eoc python3)
    PIP3INSTALLED=$(which pip3 2>/dev/null | grep -Eoc pip3)
    if ((!$AWSINSTALLED)); then
        echo -e "AWS Command Line Interface is not installed. Checking dependencies and installing ..."
        if ((!$PIP3INSTALLED)); then 
            sudo apt-get update -y &>/dev/null
            if ((!$PYTHON3INSTALLED)); then
                sudo apt-get install -y python3 &>/dev/null
            fi
            sudo apt-get install -y python3-pip &>/dev/null
        fi
        pip3 install awscli --upgrade --user &>/dev/null
    fi
fi
echo -e "AWS Command Line Interface is installed."
echo -e "Checking AWS CLI configuration ..."

if [[ ! -d "$AWS_CFG_DIR" ]]; then
    echo -e "AWS CLI configuration is not present. Creating ..."
    mkdir "$AWS_CFG_DIR"
fi
if [[ -e "$AWS_CFG_FILE" ]]; then
    UNIQUEID=$(date +%m%d%y-%H%M%S-%N)
    mv "$AWS_CFG_FILE"  "$AWS_CFG_FILE-$UNIQUEID" 
    echo -e "AWS CLI configuration exists. Saving to [$AWS_CFG_FILE-$UNIQUEID]"
fi
if [[ -e "$AWS_CREDENTIALS_FILE" ]]; then 
    UNIQUEID=$(date +%m%d%y-%H%M%S-%N)
    mv "$AWS_CREDENTIALS_FILE"  "$AWS_CREDENTIALS_FILE-$UNIQUEID"
    echo -e "AWS CLI credentials exist. Saving to [$AWS_CREDENTIALS_FILE-$UNIQUEID]"
fi

echo -e "[default]" >> "$AWS_CFG_FILE"
echo -e "output = $AWS_OUTPUT" >> "$AWS_CFG_FILE"
echo -e "region = $AWS_REGION" >> "$AWS_CFG_FILE"
echo -e "Created [$AWS_CFG_FILE] with [output=$AWS_OUTPUT] & [region=$AWS_REGION]."

echo -e "[default]" >> "$AWS_CREDENTIALS_FILE"
echo -e "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> "$AWS_CREDENTIALS_FILE"
echo -e "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> "$AWS_CREDENTIALS_FILE"
echo -e "Created [$AWS_CREDENTIALS_FILE] with supplied id & secret."

echo -e "AWS CLI configuration completed!"
