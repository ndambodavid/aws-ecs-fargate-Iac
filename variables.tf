variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "crypto-app"
}

variable "container_image" {
  description = "Docker image to deploy"
  type        = string
  default     = "377027906194.dkr.ecr.us-east-1.amazonaws.com/crypto-project:ba75ec4"
}

variable "container_port" {
  description = "Port the container listens on"
  type        = number
  default     = 5000
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 2
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