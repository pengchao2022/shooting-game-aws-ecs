output "frontend_url" {
  description = "URL of the frontend application"
  value       = "http://${aws_lb.frontend.dns_name}"
}

output "backend_url" {
  description = "URL of the backend API"
  value       = "http://${aws_lb.backend.dns_name}:8000"
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "frontend_service_name" {
  description = "Frontend ECS service name"
  value       = aws_ecs_service.frontend.name
}

output "backend_service_name" {
  description = "Backend ECS service name"
  value       = aws_ecs_service.backend.name
}