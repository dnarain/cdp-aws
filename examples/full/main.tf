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
