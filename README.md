# cdp-aws
 
Various bits of terraform required to create AWS artifacts that CDP needs.  I've placed each in its own directory as they're designed to run independent of each other.  We currently have:
- VPC/ - create the VPC structure that is needed for the CCM/Private IPs feature to work
- IAM/ - create IAM Policies & Roles required by CDP (as per documentation - link to https://docs.cloudera.com/management-console/cloud/environments/topics/mc-idbroker-minimum-setup.html)

How to use

1. Install & Configure TerraForm for your AWS account (either via a awcli profile or by entering your access key)
2. cd into the appropriate directory (iam for IAM, vpc for VPC...)
- Edit aws.tf to provide your AWS credentials
- Run terraform init
- Edit aws.tf to point to your AWS credentials
- Run terraform plan to do a dry run
- Run terraform init to do the real thing
- If you would like your generated objects to have a prefix, then use:
   terraform apply -var="PREFIX=ThisIsMyPrefix_"

3. Run it: "terraform plan" to test and "terraform apply" for reals
4. If you would like your IAM roles and policies to be have a prefix, then use:
    terraform apply -var="PREFIX=MyPrefix_"

