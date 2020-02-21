##   Terraform to set up a VPC for CDP w/ CCM (Private IPs) enabled
##   dnarain@cloudera.com

## Connect this to your AWS account - either provide a region/profile or
## alternatively the access_key/secret-key 

provider "aws" {
    region = "us-east-1"
    profile = "aws-pm-cdp-sandbox-env"
#   access_key = ""
#   secret_key = ""
}
