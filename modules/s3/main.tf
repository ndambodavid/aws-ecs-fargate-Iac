# 1. Create the S3 bucket
# We only define the bucket name here. All other configurations
# are attached as separate resources.
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

# 2. Set the Access Control List (ACL)
# This sets the bucket ACL to 'private' (recommended).
# resource "aws_s3_bucket_acl" "this" {
#   bucket = aws_s3_bucket.this.id
#   acl    = "private"
# }

# 3. Configure server-side encryption
# This replaces the deprecated 'server_side_encryption_configuration' block.
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Configure versioning
# This replaces the deprecated 'versioning' block.
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 5. Block all public access
# This resource remains the same as it is the correct way
# to secure a private bucket.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 6. Create the "folder" (key prefix)
# This is unchanged and creates an empty object to represent the folder.
resource "aws_s3_object" "folder" {
  bucket       = aws_s3_bucket.this.id
  key          = "${var.key_prefix}/"
  content_type = "application/x-directory"
  content      = ""
}