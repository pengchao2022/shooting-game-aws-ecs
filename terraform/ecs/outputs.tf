output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_service_name" {
  value = aws_ecs_service.game_service.name
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}
