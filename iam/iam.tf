##   Terraform to set up a VPC for CDP Public Cloud w/ CCM (Private IPs) enabled
##   dnarain@cloudera.com

## This TF will create the following artifacts in your AWS IAM:
## 4x IAM Roles:
## - IDBROKER_ROLE
## - LOG_ROLE
## - DATALAKE_ADMIN_ROLE
## - RANGER_AUDIT_ROLE
## 6x Permissions Policies:
## - aws-cdp-log-policy
## - aws-cdp-ranger-audit-s3-policy
## - aws-cdp-datalake-admin-s3-policy
## - aws-cdp-bucket-access-policy
## - aws-cdp-dynamodb-policy
## - aws-cdp-idbroker-assume-role

## All artifact are named as per CDP Public Clod Documentation 
## https://docs.cloudera.com/management-console/cloud/environments/topics/mc-idbroker-minimum-setup.html

# If you want the generated artifacts to have a prefix to their name, then 
# specify by using -var argument on the command line
# e.g. terraform appy -var="PREFIX=MyPrefix_"

## All policies are in the json_for_policies directory and are copied from:
## https://github.com/hortonworks/cloudbreak/tree/master/cloud-aws/src/main/resources/definitions/cdp


### THESE VARIABLES WILL BE REQUESTED ON THE COMMAND LINE
variable "DATALAKE_BUCKET" {
  type = string
  description = << EOF
  "Enter the path to the S3 bucket for the datalake (without the leading  s3://) "
  EOF
}

### Enhancement TODO: Use bucket-s3a as the table name so that the 
### user has one less thing to remember
variable "DYNAMODB_TABLE_NAME" {
 type = string
 default = ""
 description = << EOF
 "When you create a datalke, CDP will require the name of a DynamoDB table for 
  s3a to use. Please specify this here. If you plan to create multiple datalakes
  you can also use a wildcard - e.g. AllMyS3aTables-*"
  EOF 
}

### THESE VARIABLES CAN BE SET BY COMMAND LINE FLAGS
### e.g. use terraform apply -var="PREFIX=MyPrefix_"

variable "PREFIX" {
  default = ""
  description = "Prefix for names of created objects (e.g. CDPPOC_)"
}

data "aws_caller_identity" "current" {}

// Local variables
locals {
  policies_dir = "${path.root}/json_for_policies"
  LOGS_PATH = "logs"
  STORAGE_LOCATION_PATH = "datalake"
}

// IDBROKER_ROLE and associated Instance Profile
resource "aws_iam_role" "idbroker" {
  name = "${var.PREFIX}IDBROKER_ROLE"
  path = "/"

  assume_role_policy = replace(file("${local.policies_dir}/aws-cdp-ec2-role-trust-policy.json"),
    "Allow",
    "Allow"
    )
}
resource "aws_iam_instance_profile" "idbroker" {
  name = "${var.PREFIX}IDBROKER_ROLE"
  role = aws_iam_role.idbroker.name
}

// LOG_ROLE and associated Instance Profile 
resource "aws_iam_role" "log" {
  name = "${var.PREFIX}LOG_ROLE"
  path = "/"

  assume_role_policy = replace(file("${local.policies_dir}/aws-cdp-ec2-role-trust-policy.json"),
    "Allow",
    "Allow",
    )
}

resource "aws_iam_instance_profile" "log" {
  name = "${var.PREFIX}LOGS_ROLE"
  role = aws_iam_role.log.name
}

// RANGER_AUDIT_ROLE
resource "aws_iam_role" "ranger_audit" {
  name = "${var.PREFIX}RANGER_AUDIT_ROLE"
  path = "/"

  assume_role_policy = replace(templatefile("${local.policies_dir}/aws-cdp-idbroker-role-trust-policy.json",
            { AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id,
              IDBROKER_ROLE = aws_iam_role.idbroker.name
            }
           ),
      "Allow",
      "Allow"
    )
}

// DATALAKE_ADMIN_ROLE
resource "aws_iam_role" "datalake_admin" {
      name="${var.PREFIX}DATALAKE_ADMIN_ROLE"
  path="/"
  assume_role_policy = replace(templatefile("${local.policies_dir}/aws-cdp-idbroker-role-trust-policy.json",
    { AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id,
      IDBROKER_ROLE = aws_iam_role.idbroker.name
    }
    ),
    "Allow",
   "Allow"
    )

}

// Now the policies that go behind these roles 

resource "aws_iam_policy" "aws_cdp_log_policy" {
  name = "${var.PREFIX}aws-cdp-log-policy"
  policy = templatefile("${local.policies_dir}/aws-cdp-log-policy.json",
    { LOGS_LOCATION_BASE = "${var.DATALAKE_BUCKET}/${local.LOGS_PATH}" ,
      STORAGE_LOCATION_BASE = "${var.DATALAKE_BUCKET}/${local.STORAGE_LOCATION_PATH}",
      DATALAKE_BUCKET = "${var.DATALAKE_BUCKET}"
      DYNAMODB_TABLE_NAME = "${var.DYNAMODB_TABLE_NAME}"
    }
    )
}

resource "aws_iam_policy" "aws_cdp_ranger_audit_s3_policy" {
  name="${var.PREFIX}aws-cdp-ranger-audit-s3-policy"
  policy = templatefile("${local.policies_dir}/aws-cdp-ranger-audit-s3-policy.json",
    { LOGS_LOCATION_BASE = "${var.DATALAKE_BUCKET}/${local.LOGS_PATH}" ,
      STORAGE_LOCATION_BASE = "${var.DATALAKE_BUCKET}/${local.STORAGE_LOCATION_PATH}",
      DATALAKE_BUCKET = "${var.DATALAKE_BUCKET}"
      DYNAMODB_TABLE_NAME = "${var.DYNAMODB_TABLE_NAME}"
    }
    )
}

resource "aws_iam_policy" "aws_cdp_datalake_admin_s3_policy" {
  name="${var.PREFIX}aws-cdp-datalake-admin-s3-policy"
  policy = templatefile("${local.policies_dir}/aws-cdp-datalake-admin-s3-policy.json",
    { LOGS_LOCATION_BASE = "${var.DATALAKE_BUCKET}/${local.LOGS_PATH}" ,
      STORAGE_LOCATION_BASE = "${var.DATALAKE_BUCKET}/${local.STORAGE_LOCATION_PATH}",
      DATALAKE_BUCKET = "${var.DATALAKE_BUCKET}"
      DYNAMODB_TABLE_NAME = "${var.DYNAMODB_TABLE_NAME}"
    }
    )
}


resource "aws_iam_policy" "aws_cdp_idbroker_assume_role" {
  name = "${var.PREFIX}aws-cdp-idbroker-assume-role"
  policy = file("${local.policies_dir}/aws-cdp-idbroker-assume-role-policy.json")
}




resource "aws_iam_policy" "aws_cdp_bucket_access_policy" {
  name="${var.PREFIX}aws-cdp-bucket-access-policy"
  policy = replace(templatefile("${local.policies_dir}/aws-cdp-bucket-access-policy.json",
    { LOGS_LOCATION_BASE = "${var.DATALAKE_BUCKET}/${local.LOGS_PATH}" ,
      STORAGE_LOCATION_BASE = "${var.DATALAKE_BUCKET}/${local.STORAGE_LOCATION_PATH}",
      DATALAKE_BUCKET = "${var.DATALAKE_BUCKET}"
      DYNAMODB_TABLE_NAME = "${var.DYNAMODB_TABLE_NAME}"
    }
    ),
    "s3:CreateJob",
    "s3:ListJobs"
    )
}


resource "aws_iam_policy" "aws_cdp_dynamodb_policy" {
  name="${var.PREFIX}aws-cdp-dynamodb-policy"
  policy = templatefile("${local.policies_dir}/aws-cdp-dynamodb-policy.json",
    { LOGS_LOCATION_BASE = "${var.DATALAKE_BUCKET}/${local.LOGS_PATH}" ,
      STORAGE_LOCATION_BASE = "${var.DATALAKE_BUCKET}/${local.STORAGE_LOCATION_PATH}",
      DATALAKE_BUCKET = "${var.DATALAKE_BUCKET}"
      DYNAMODB_TABLE_NAME = "${var.DYNAMODB_TABLE_NAME}"
    }
    )
}

// attaching policies to roles

// Log role
resource "aws_iam_role_policy_attachment" "log_role_to_log_policy_s3access" {
  role = aws_iam_role.log.name
  policy_arn = aws_iam_policy.aws_cdp_log_policy.arn
}


  
// idbroker_role
resource "aws_iam_role_policy_attachment" "idbroker_role_to_assume_role_policy" {
  role = aws_iam_role.idbroker.name
  policy_arn = aws_iam_policy.aws_cdp_idbroker_assume_role.arn
}


// Ranger Audit Role
resource "aws_iam_role_policy_attachment" "ranger_audit_role_to_range_audit_policy_s3access" {
  role = aws_iam_role.ranger_audit.name
  policy_arn = aws_iam_policy.aws_cdp_ranger_audit_s3_policy.arn
}

resource  "aws_iam_role_policy_attachment" "ranger_audit_role_to_bucket_policy_s3_access" {
  role = aws_iam_role.ranger_audit.name
  policy_arn = aws_iam_policy.aws_cdp_ranger_audit_s3_policy.arn
}


// Datalake admin
resource "aws_iam_role_policy_attachment" "datalake_admin_role_to_datalake_admin_policy_s3access" {
  role = aws_iam_role.datalake_admin.name
  policy_arn = aws_iam_policy.aws_cdp_bucket_access_policy.arn
}

resource  "aws_iam_role_policy_attachment" "datalake_admin_role_to_dynamodb_policy" {
  role = aws_iam_role.datalake_admin.name
  policy_arn = aws_iam_policy.aws_cdp_dynamodb_policy.arn
}
