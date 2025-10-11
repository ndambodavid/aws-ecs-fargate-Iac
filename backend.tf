terraform {
  backend "s3" {
    bucket         = "my-ecs-terraform-state"  # S3 bucket to store the Terraform state file
    key            = "ecs/terraform.tfstate"   # Path (key) to the state file within the bucket
    region         = "us-east-1"               # AWS region where the bucket and DynamoDB table exist
    dynamodb_table = "terraform-locks"         # DynamoDB table used to lock the state file to avoid race conditions
    encrypt        = true                      # Encrypt the state file at rest using S3 server-side encryption
  }
}