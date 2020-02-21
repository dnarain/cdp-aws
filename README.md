# cdp-aws
 
This repo contains various bits to make it easier to bring up Cloudera Data Platform (CDP) Public Cloud up in AWS.

I've placed each in its own directory as they're designed to run independent of each other.  We currently have:
- S3/  - Create the S3 bucket with Default Encryption and the logs folder 
- VPC/ - Create the VPC structure that is needed for the CCM/Private IPs feature to work
- IAM/ - Create IAM Policies & Roles as per [CDP documentation](https://docs.cloudera.com/management-console/cloud/environments/topics/mc-idbroker-minimum-setup.html)

How to use

1. Install & Configure Terraform for your AWS account (either via a aws cli profile or by entering your access key)
2. cd into the appropriate directory (s3, iam or vpc)
3. Edit the provider info in aws.tf to link terraform to your aws account.  You can either provide your access key/secret access key in this file itself, or you can set up an IAM role and use via in your ~/.aws/credentials file.  For details on all your options, please visit the [official terraform documentation](https://www.terraform.io/docs/providers/aws/index.html)
4. Run `terraform init` 
5. Run `terraform plan` to do a dry run and `terraform apply` to do the real thing
6. You may be asked to provide some information:
- S3 will ask you for the name of the bucket
- IAM will ask you for the name of the bucket
7. If you would like generated IAM & VPC object names to have a prefix, use:
   `terraform apply -var="PREFIX=ThisIsMyPrefix_"`

Video Instructions
- IAM: https://youtu.be/CStOiWKmb28
- S3:  https://youtu.be/pu_Y_EpYvps
- VPC: https://youtu.be/93-qsSTSXX0

 PS: Don't forget to set up a ssh tunnel or a proxy in a bastion host so that you can access the CDP endpoints from your network.
