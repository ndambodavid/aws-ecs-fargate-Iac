variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "sensitive_keys" {
  description = "List of keys to create in Secrets Manager"
  type        = list(string)
}

variable "secret_defaults" {
  description = "Map of initial values for the secrets"
  type        = map(string)
  sensitive   = true
}

variable "gcp_key_file_path" {
  description = "Local path to the GCP service account JSON key"
  type        = string
  default     = ""
}