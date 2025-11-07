variable "bucket_name" {
  description = "The name for the S3 artifacts bucket."
  type        = string
}

variable "key_prefix" {
  description = "The name of the 'folder' (key prefix) to create for artifacts."
  type        = string
}
