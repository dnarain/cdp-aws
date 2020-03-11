module "cdp-iam" {
  source = "../../modules/iam"

  DATALAKE_BUCKET = var.bucket_name
  PREFIX = var.deployment_name_prefix
}