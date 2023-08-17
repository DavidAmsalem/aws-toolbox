#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq could not be found. Trying to install..."
    sudo apt-get update -y && sudo apt-get install jq -y
fi

# Extract information about the Instance
META_ENDPOINT="http://169.254.169.254/latest/meta-data"
INSTANCE_ID=$(curl -s ${META_ENDPOINT}/instance-id/)
AZ=$(curl -s ${META_ENDPOINT}/placement/availability-zone/)
MY_IP=$(curl -s ${META_ENDPOINT}/public-ipv4/)

REGION=${AZ::-1}

# Extract tags associated with the instance in one call
TAGS=$(aws ec2 describe-tags --region ${REGION} --filters "Name=resource-id,Values=${INSTANCE_ID}")

ZONE_TAG=$(echo "$TAGS" | jq -r '.Tags[] | select(.Key=="AUTO_DNS_ZONE") | .Value')
NAME_TAG=$(echo "$TAGS" | jq -r '.Tags[] | select(.Key=="AUTO_DNS_NAME") | .Value')

# Check if tags are present
if [[ -z "$ZONE_TAG" || -z "$NAME_TAG" ]]; then
    echo "Error: Unable to fetch required tags."
    exit 1
fi

# Update Route 53 Record Set based on the Name tag to the current Public IP address of the Instance
aws route53 change-resource-record-sets --hosted-zone-id $ZONE_TAG --change-batch "{\"Changes\":[{\"Action\":\"UPSERT\",\"ResourceRecordSet\":{\"Name\":\"$NAME_TAG\",\"Type\":\"A\",\"TTL\":300,\"ResourceRecords\":[{\"Value\":\"$MY_IP\"}]}}]}"
