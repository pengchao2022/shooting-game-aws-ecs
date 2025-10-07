output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
}

output "backend_ecr" {
  value = module.ecr.backend_repo_url
}

output "frontend_ecr" {
  value = module.ecr.frontend_repo_url
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
