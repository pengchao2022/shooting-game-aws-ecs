variable "aws_region" {
  description = "AWS region"
  type = string
  default = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type = string
  default = "shooting-game"
}

# Network
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type = list(string)
}

# ECR names
variable "ecr_backend_name" {
  description = "ECR repo name for backend"
  type = string
  default = "shooting-game-backend"
}
variable "ecr_frontend_name" {
  description = "ECR repo name for frontend"
  type = string
  default = "shooting-game-frontend"
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

# RDS
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
