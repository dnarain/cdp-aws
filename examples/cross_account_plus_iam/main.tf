module "cross-account-role" {
  source = "../../modules/cross-account-role"

  PREFIX = var.deployment_name_prefix
}

module "cdp-iam" {
  source = "../../modules/iam"

  DATALAKE_BUCKET = var.bucket_name
  PREFIX = var.deployment_name_prefix
}

output "cdp-cross-account-role" {
  value = module.cross-account-role.arn
}