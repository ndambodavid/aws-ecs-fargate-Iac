# ECR Repositories
resource "aws_ecr_repository" "backend" {
  name = "${var.project_name}/backend"

  # Optional: Keep images from being deleted accidentally
  # image_scanning_configuration {
  #   scan_on_push = true
  # }

  force_delete = true

  # Optional: Keep untagged images, 'untagged' is the default
  image_tag_mutability = "MUTABLE"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
