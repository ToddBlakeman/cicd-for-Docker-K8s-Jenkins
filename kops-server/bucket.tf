resource "aws_s3_bucket" "kops-bucket" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}
