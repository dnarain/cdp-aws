# cdp-aws
 
This repo contains various bits to make it easier to bring up Cloudera Data Platform (CDP) Public Cloud up in AWS.

I've placed each in its own directory as they're designed to run independent of each other.  We currently have:
- VPC/ - Terraform to create the VPC structure that is needed for the CCM/Private IPs feature to work
- IAM/ - Terraform to create IAM Policies & Roles ras per [CDP documentation](https://docs.cloudera.com/management-console/cloud/environments/topics/mc-idbroker-minimum-setup.html)

How to use

1. Install & Configure Terraform for your AWS account (either via a aws cli profile or by entering your access key)
2. cd into the appropriate directory (iam for IAM, vpc for VPC)
3. Edit the provider info in aws.tf to link terraform to your aws account.  You can either provide your access key/secret access key in this file itself, or you can set up an IAM role and use via in your ~/.aws/credentials file.  For details on all your options, please visit the [official terraform documentation](https://www.terraform.io/docs/providers/aws/index.html)
4. Run `terraform init` 
5. Run `terraform plan` to do a dry run and `terraform init` to do the real thing
6. The IAM setup will ask you for 2 variables 
- the path to the of the S3 folder for the datalake (you can use wildcards)
- the name of the DynamoDB table that S3Guard will use (you can use wildcards e.g. * for any table)
7. If you would like generated objects to have a prefix in their name, you can use:
   `terraform apply -var="PREFIX=ThisIsMyPrefix_"`
   
 PS: Don't forget to set up a ssh tunnel or a proxy in a bastion host so that you can access the CDP endpoints from outside.
