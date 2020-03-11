variable "deployment_name_prefix" {
  default = "CDP1_"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_azs" {
  default = [ "us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "bucket_name" {
  default = "sre-cdp-test"
}