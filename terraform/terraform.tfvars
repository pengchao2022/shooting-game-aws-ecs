aws_region = "us-east-1"
project_name = "shooting-game"

# VPC and subnets
vpc_cidr = "10.10.0.0/16"

public_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

private_subnet_cidrs = [
  "10.10.101.0/24",
  "10.10.102.0/24"
]

# RDS
db_name     = "gamedb"
db_username = "gameadmin"
db_password = "game_1234"

# ECR names (optional override)
ecr_backend_name  = "shooting-game-backend"
ecr_frontend_name = "shooting-game-frontend"
