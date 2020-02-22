##   Terraform to set up a S3 for CDP w/ Default Encryption enabled
##   and 2 folders - datalake/ and logs/
##   dnarain@cloudera.com

## Connect this to your AWS account - either provide a region/profile or
## alternatively the access_key/secret-key 

provider "aws" {
    region = "us-east-1"
    profile = "xyzzx"
#   access_key = ""
#   secret_key = ""
}
