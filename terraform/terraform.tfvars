aws_region   = "us-east-1"
project_name = "shooting-game"
vpc_cidr     = "10.0.0.0/16"

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

db_username = "gameadmin"
db_password = "game_1234"
db_name     = "shootinggame"

frontend_image = "dummy-frontend-image"
backend_image  = "dummy-backend-image"