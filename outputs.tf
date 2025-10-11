output "alb_endpoint" {
  description = "Public DNS name of the ALB"
  value       = module.alb.alb_dns_name
}