# cdp-aws
 
Various bits of terraform required to create AWS artifacts that CDP needs.  I've placed each in its own directory as they're designed to run independent of each other.  We currently have:
- VPC/ - create the VPC structure that is needed for the CCM/Private IPs feature to work
- IAM/ - create IAM Policies & Roles required by CDP (as per documentation - link to https://docs.cloudera.com/management-console/cloud/environments/topics/mc-idbroker-minimum-setup.html)

How to use

1. Install & Configure TerraForm for your AWS account (either via a awcli profile or by entering your access key)
2. cd into the appropriate directory (iam for IAM, vpc for VPC...)
3. Edit the provider info to link terraform to your aws account
4. Run terraform init
5. Run terraform plan to do a dry run
6. Run terraform init to do the real thing
7. If you would like generated objects to have a prefix in their name, then use:
   terraform apply -var="PREFIX=ThisIsMyPrefix_"

