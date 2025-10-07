terraform {
  required_version = ">= 1.4.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure a backend for remote state, e.g. s3
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "shooting-game/terraform.tfstate"
  #   region = var.aws_region
  # }
}

provider "aws" {
  region = var.aws_region
}

# VPC module
module "vpc" {
  source = "./vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  aws_region = var.aws_region
}

# ECR module
module "ecr" {
  source   = "./ecr"
  repo_backend_name  = var.ecr_backend_name
  repo_frontend_name = var.ecr_frontend_name
}

# IAM module
module "iam" {
  source = "./iam"
  project_name = var.project_name
}

# ECS module
module "ecs" {
  source          = "./ecs"
  cluster_name    = var.ecs_cluster_name
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids
  ecr_repo_url    = module.ecr.repo_url

  db_endpoint  = module.rds.rds_endpoint
  db_username  = var.db_username
  db_password  = var.db_password
  db_name      = var.db_name
}

# RDS module
module "rds" {
  source = "./rds"

  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  subnets           = module.vpc.private_subnet_ids
  security_group_id = module.vpc.db_security_group_id
}

