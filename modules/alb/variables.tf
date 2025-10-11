variable "name_prefix" {}
variable "vpc_id" {}
variable "public_subnet_ids" {}
variable "security_group_ids" {}
variable "target_port" {
  default = 80
}
variable "environment" {
  default = "dev"
}