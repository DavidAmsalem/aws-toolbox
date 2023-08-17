# AWS EC2 Auto DNS Update Script
##### This script is designed to automatically fetch specific EC2 instance tags and then update the AWS Route53 DNS records accordingly. It uses the EC2 instance metadata service and the AWS CLI to achieve this.

+ [Prerequisites](#prerequisites)
+ [Steps to Follow](#steps-to-follow)
+ [Run the Script](#copy-the-script)
+ [Logs & Errors](#logs-&-errors)

## Prerequisites
1. AWS CLI: The script uses the AWS CLI to fetch tags from the EC2 instance and update Route53 DNS records. Ensure the AWS CLI is installed and properly configured with the necessary permissions.

1. Create tags for the ec2 instance with keys: AUTO_DNS_NAME <sup>example.com</sup> and AUTO_DNS_ZONE [find-yours](https://console.aws.amazon.com/route53/) click on 'hosted zones' in the side panel and click on your domain name [^1].

1. jq: A lightweight and flexible command-line JSON processor. If it's not already installed on your system, the script will attempt to install it.

1. IAM Permissions: Ensure the EC2 instance role has the necessary permissions. The following IAM policy should be attached to the EC2 instance role:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags",
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```

4. Tags on EC2: The EC2 instance should have the tags AUTO_DNS_ZONE and AUTO_DNS_NAME. The AUTO_DNS_ZONE tag should have the Route 53 Hosted Zone ID as its value, and AUTO_DNS_NAME should have the desired DNS name for the instance.

## Steps to Follow
##### 1. Clone the Repository:
```bash
git clone https://github.com/DavidAmsalem/aws-toolbox/tree/main
cd aws-toolbox
```
##### 2. Copy the Script
Copy the script into to the boot folder:
```bash
sudo cp ./set-route-53.sh /var/lib/cloud/scripts/per-boot/set-route-53.sh
```
##### 3. Run the Script:
```bash
./set-route-53.sh
```
##### The script will then:

+ Check and install jq if it's not present.
+ Fetch the EC2 instance ID, availability zone, and public IP from the instance metadata.
+ Fetch the required tags (AUTO_DNS_ZONE and AUTO_DNS_NAME) using the AWS CLI.

##### 4. Logs & Errors: 
Check any output from the script for success or error messages. If there's a permissions issue, ensure the EC2 instance role has the necessary IAM policy attached.

#### Contributing
If you'd like to contribute, please fork the repository and use a feature branch. Pull requests are warmly welcome.

#### Licensing
This project is licensed under the MIT License. See the [LICENSE](https://github.com/git/git-scm.com/blob/main/MIT-LICENSE.txt) file for more information.

[^1]: If you didn't already create a hosted zone for your domain name follow [this](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html)
