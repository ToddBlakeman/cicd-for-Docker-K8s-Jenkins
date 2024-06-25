variable "region" {
  description = "AWS region"
}

variable "access_key" {
  description = "my AWS_ACCESS_KEY_ID"
}

variable "secret_key" {
  description = "my AWS_SECRET_ACCESS_KEY"
}

variable "bucket_name" {
  description = "S3 Bucket Name"
}

variable "domain_Name" {
  description = "Domain name for Kops-Server DNS record"
  type        = string
}