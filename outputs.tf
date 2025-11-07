output "alb_endpoint" {
  description = "Public DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "s3_artifact_url" {
  description = "The url of the s3 artifact bucket"
  value = module.s3_artifacts.bucket_path
}

output "ecs_cluster_id" {
  description = "ECS cluster id"
  value       = module.ecs.cluster_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_id" {
  description = "ECS service id"
  value       = module.ecs_service.service_id
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs_service.service_name
}

output "ecs_task_family" {
  description = "ECS task family"
  value        = module.ecs_task_definition.task_definition_family
}