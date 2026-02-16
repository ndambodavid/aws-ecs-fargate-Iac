variable "container_name" {
  description = "Name of the container"
  type        = string
  default     = "ambulensi-server"
}

variable "container_image" {
  description = "Docker image to deploy"
  type        = string
  default     = "619316659327.dkr.ecr.us-east-1.amazonaws.com/ambulensi/server:kafka"
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
  default     = 2048
}

variable "memory" {
  description = "Memory (in MiB) for the ECS task"
  type        = number
  default     = 4096
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
  default     = "ambulensi-mobile-server"
}

variable "secret_defaults" {
  type = map(string)
}

variable "sensitive_keys" {
  type = list(string)
}

variable "app_env_vars" {
  type = map(string)
}

