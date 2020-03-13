module "cross-account-role" {
  source = "../../modules/cross-account-role"

  PREFIX = var.deployment_name_prefix
}

module "cdp-vpc" {
  source = "../../modules/vpc"

  PREFIX = var.deployment_name_prefix
  VPC_CIDR = var.vpc_cidr
  AZs = var.vpc_azs
}

module "cdp-s3" {
  source = "../../modules/s3"

  DATALAKE_BUCKET = var.bucket_name
}

module "cdp-iam" {
  source = "../../modules/iam"

  DATALAKE_BUCKET = var.bucket_name
  PREFIX = var.deployment_name_prefix
}

output "cdp-cross-account-role" {
  value = module.cross-account-role.arn
}

output "Logs-Select-an-Instance-Profile" {
  value = "TBD"
}
output "Logs-Location-Base" {
  value = "s3a://${var.bucket_name}/logs"
}

output "Ranger-Audit-Role" {
  value = "TBD"
}

output "Data-Access-Select-an-Instance-Profile" {
  value = "TBD"
}
output "Storage-Location-Base" {
  value = "s3a://${var.bucket_name}"
}
