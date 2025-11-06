variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "nest-app"
}

variable "container_image" {
  description = "Docker image to deploy"
  type        = string
  default     = "619316659327.dkr.ecr.us-east-1.amazonaws.com/terraform-rnd-app/backend:dev"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 3000
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "CPU units for the ECS task"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory (in MiB) for the ECS task"
  type        = number
  default     = 512
}

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "terraform-rnd-app"
}