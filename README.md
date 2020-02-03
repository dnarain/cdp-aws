# cdp-aws
 
Various bits of terraform required to create AWS artifacts that CDP needs.  I've placed each in its own directory as they're designed to run independent of each other.  We currently have:
- VPC/ - create the VPC structure that is needed for the CCM/Private IPs feature to work
- IAM/ - create IAM Policies & Roles ras per [CDP documentation][https://docs.cloudera.com/management-console/cloud/environments/topics/mc-idbroker-minimum-setup.html)

How to use

1. Install & Configure TerraForm for your AWS account (either via a awcli profile or by entering your access key)
2. cd into the appropriate directory (iam for IAM, vpc for VPC...)
3. Edit the provider info in aws.tf to link terraform to your aws account.  You can either provide your access key/secret access key, or set up an IAM role and use it in your ~/.aws/credentials file.  For details on all your options, please visit the [official terraform documentation][https://www.terraform.io/docs/providers/aws/index.html]
4. Run terraform init to initialize terraform
5. Run terraform plan to do a dry run and terraform init to do the real thing
6. The IAM setup will ask you for 3 
7. If you would like generated objects to have a prefix in their name, then use:
   terraform apply -var="PREFIX=ThisIsMyPrefix_"

