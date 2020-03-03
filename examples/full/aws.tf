##   Terraform to set up a VPC for CDP w/ CCM (Private IPs) enabled
##   dnarain@cloudera.com

## Connect this to your AWS account - either provide a region/profile or
## alternatively the access_key/secret-key 

variable "aws_profile" {
}

variable "aws_region" {
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
  version = "~> 2.39"
}

