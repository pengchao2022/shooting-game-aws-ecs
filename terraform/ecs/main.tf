# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.project_name}"

  tags = {
    Name = "${var.project_name}-logs"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# Backend Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([{
    name  = "backend"
    image = var.backend_image
    portMappings = [{
      containerPort = 8000
      hostPort      = 8000
      protocol      = "tcp" # 明确指定协议
    }]
    environment = [
      {
        name  = "DATABASE_URL"
        value = "postgresql://${var.db_username}:${var.db_password}@${var.db_endpoint}/${var.db_name}"
      },
      {
        name  = "SECRET_KEY"
        value = "your-secret-key-change-in-production"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "backend"
      }
    }
    # 添加健康检查
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:8000/ || exit 1"]
      interval    = 30
      timeout     = 10
      retries     = 3
      startPeriod = 60
    }
  }])

  tags = {
    Name = "${var.project_name}-backend-task"
  }
}

# Frontend Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([{
    name  = "frontend"
    image = var.frontend_image
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp" # 明确指定协议
    }]
    environment = [
      {
        name  = "REACT_APP_API_URL"
        value = "http://${aws_lb.backend.dns_name}:8000"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main.name
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "frontend"
      }
    }
    # 添加健康检查
    healthCheck = {
      command     = ["CMD-SHELL", "curl -f http://localhost:80/ || exit 1"]
      interval    = 30
      timeout     = 10
      retries     = 3
      startPeriod = 60
    }
  }])

  tags = {
    Name = "${var.project_name}-frontend-task"
  }
}

# Load Balancer - Backend (修改为 Application Load Balancer)
resource "aws_lb" "backend" {
  name               = "${var.project_name}-backend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.backend_security_group_id] # 添加安全组
  subnets            = var.public_subnet_ids           # 改为公有子网以便从外网访问

  tags = {
    Name = "${var.project_name}-backend-lb"
  }
}

# Load Balancer - Frontend
resource "aws_lb" "frontend" {
  name               = "${var.project_name}-frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.frontend_security_group_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-frontend-lb"
  }
}

# Target Group - Backend (新创建，避免配置冲突)
resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-backend-tg-new" # 新名称避免冲突
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 10
    interval            = 30
    path                = "/" # 使用根路径
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-backend-tg"
  }

  # 添加生命周期配置，确保在更新时先创建新的
  lifecycle {
    create_before_destroy = true
  }
}

# Target Group - Frontend
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 10
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-frontend-tg"
  }
}

# Listener - Backend
resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  tags = {
    Name = "${var.project_name}-backend-listener"
  }
}

# Listener - Frontend
resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  tags = {
    Name = "${var.project_name}-frontend-listener"
  }
}

# ECS Service - Backend
resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1 # 先设置为1，稳定后再增加
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.backend_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8000
  }

  # 添加健康检查宽限期
  health_check_grace_period_seconds = 180

  # 添加部署配置
  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [aws_lb_listener.backend]

  tags = {
    Name = "${var.project_name}-backend-service"
  }

  # 防止 Terraform 忽略负载均衡器变更
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# ECS Service - Frontend
resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.frontend_security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }

  # 添加健康检查宽限期
  health_check_grace_period_seconds = 120

  # 添加部署配置
  deployment_controller {
    type = "ECS"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [aws_lb_listener.frontend]

  tags = {
    Name = "${var.project_name}-frontend-service"
  }

  # 防止 Terraform 忽略负载均衡器变更
  lifecycle {
    ignore_changes = [desired_count]
  }
}