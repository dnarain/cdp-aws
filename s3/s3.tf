##   Terraform to set up a S3 bucket for CDP datalake
##   dnarain@cloudera.com

### Create the bucket
### Enable default encryption
### Create logs folder and datalake folder


### THESE VARIABLES WILL BE REQUESTED ON THE COMMAND LINE
variable "DATALAKE_BUCKET" {
  type = string
  description = <<EOF
  Enter the bucket name for the datlake (without the leading  s3://).
  If the bucket doesn't exist, it will be created. 
  Default encryption will be enabled (even for pre-existing buckets)
  A folder called logs will be created in this bucket
   NOTE: terraform destroy WILL destroy the bucket, even if it pre-existed
  EOF
}


resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "the_bucket" {
  bucket = var.DATALAKE_BUCKET
  tags = {
    Name        = var.DATALAKE_BUCKET
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.mykey.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_object" "datalake_folder" {
    bucket  = aws_s3_bucket.the_bucket.id
    key     =  "datalake/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "logs_folder" {
    bucket  = aws_s3_bucket.the_bucket.id
    key     =  "logs/"
    content_type = "application/x-directory"
}