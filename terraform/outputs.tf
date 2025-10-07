output "frontend_url" {
  description = "URL of the frontend application"
  value       = module.ecs.frontend_url
}

output "backend_url" {
  description = "URL of the backend API"
  value       = module.ecs.backend_url
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "ecr_frontend_repository_url" {
  description = "ECR repository URL for frontend"
  value       = module.ecr.frontend_repository_url
}

output "ecr_backend_repository_url" {
  description = "ECR repository URL for backend"
  value       = module.ecr.backend_repository_url
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.ecs_cluster_name
}

output "frontend_url" {
  description = "URL of the frontend application"
  value       = module.ecs.frontend_url
}

output "backend_url" {
  description = "URL of the backend API"
  value       = module.ecs.backend_url
}


output "frontend_service_name" {
  description = "Frontend ECS service name"
  value       = module.ecs.frontend_service_name
}

output "backend_service_name" {
  description = "Backend ECS service name"
  value       = module.ecs.backend_service_name
}