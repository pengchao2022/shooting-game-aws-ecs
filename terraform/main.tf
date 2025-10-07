terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

provider "aws" {
  region = var.aws_region
}

# 获取可用区信息
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC 模块
module "vpc" {
  source = "./vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = data.aws_availability_zones.available.names
}

# ECR 模块
module "ecr" {
  source = "./ecr"

  project_name = var.project_name
}

# IAM 模块
module "iam" {
  source = "./iam"

  project_name = var.project_name
}

# 安全组模块
module "security_groups" {
  source = "./security_groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id

  backend_security_group_id = module.security_groups.backend_sg_id
}

# RDS 模块
module "rds" {
  source = "./rds"

  project_name           = var.project_name
  db_username            = var.db_username
  db_password            = var.db_password
  db_name                = var.db_name
  private_subnet_ids     = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.security_groups.rds_sg_id]
}

# ECS 模块
module "ecs" {
  source = "./ecs"

  project_name       = var.project_name
  aws_region         = var.aws_region
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  frontend_image = var.frontend_image
  backend_image  = var.backend_image

  backend_security_group_id  = module.security_groups.backend_sg_id
  frontend_security_group_id = module.security_groups.frontend_sg_id
  rds_security_group_id      = module.security_groups.rds_sg_id

  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  db_endpoint                 = module.rds.db_endpoint
  db_name                     = var.db_name
  db_username                 = var.db_username
  db_password                 = var.db_password
}