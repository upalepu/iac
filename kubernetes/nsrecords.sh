#!/bin/bash
# Script to get nsrecords from domain. 
# Used by terraform. 
# External data source 
AWS=$(which aws); AWS=${#AWS}; if ((!$AWS)); then echo -e "[aws] not installed. Exiting." 1>&2; exit 1; fi
JQ=$(which jq); JQ=${#JQ}; if ((!$JQ)); then echo -e "[jq] not installed. Exiting." 1>&2; exit 1; fi
# jq retrives the JSON supplied by calling terraform & parses into variables.
eval "$(jq -r '@sh "export hosted_zone=\(.hosted_zone)"')"
# Check to see if required variables are properly received. 
if [[ "${hosted_zone}" == "null" || -z "${hosted_zone}" ]]; then 
    echo -e "Required input [hosted_zone=$hosted_zone]. Seems empty ... Exiting!" 1>&2; exit 1 
fi
# Retrieve the ns records using aws command line and convert the output into text strings. 
nsrecords=$(aws route53 list-resource-record-sets --hosted-zone-id "${hosted_zone}" \
    --output text --query 'ResourceRecordSets[?Type==`NS`].ResourceRecords[*]')
#echo -e "$nsrecords" 1>&2
# Creating the JSON for the retrieved nsrecords from the hosted zone 
# TODO: Figure out how to use jq to create a JSON map of strings. 
result="{"
i=0
while read line; do
    tmp="\"Value$i\": \"$line\","
    result="$result$tmp"
    ((i++));
done <<< "$nsrecords"
result=${result%*,}; result="$result}"
# JSON map of nsrecords strings created, output it using jq. 
echo -e "$result" | jq .
if(($?)); then echo -e "Some error. Exiting." 1>&2; exit 1; fi

