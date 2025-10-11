output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.this.name
}

output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.this.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_service.this.cluster
}

output "launch_type" {
  description = "Launch type used for the ECS service"
  value       = aws_ecs_service.this.launch_type
}
