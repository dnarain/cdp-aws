# cdp-aws
 
Generate the AWS IAM roles & policies used by CDP. The generated artifacts
are named according to the CDP Documentation 
(https://docs.cloudera.com/management-console/cloud/environments/topics/mc-idbroker-minimum-setup.html)

How to use

1. Install & Configure TerraForm for your AWS account
2. Edit aws.tf to provide your AWS credentials and 
3. Run it: "terraform plan" to test and "terraform apply" for reals
4. If you would like your IAM roles and policies to be have a prefix, then use:
    terraform apply -var="PREFIX=MyPrefix_"

