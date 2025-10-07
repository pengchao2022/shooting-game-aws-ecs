# ------------------------
# ECS Cluster
# ------------------------
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name
  tags = {
    Name = var.cluster_name
  }
}

# ------------------------
# ECS Task Execution Role
# ------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster_name}-ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ------------------------
# Security Group for ECS Tasks
# ------------------------
resource "aws_security_group" "ecs_sg" {
  vpc_id = var.vpc_id
  name   = "${var.cluster_name}-ecs-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-ecs-sg"
  }
}

# ------------------------
# Application Load Balancer (ALB)
# ------------------------
resource "aws_lb" "app_lb" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [aws_security_group.ecs_sg.id]
  tags = {
    Name = "${var.cluster_name}-alb"
  }
}

resource "aws_lb_target_group" "ecs_tg" {
  name     = "${var.cluster_name}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.cluster_name}-tg"
  }
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

# ------------------------
# ECS Task Definition
# ------------------------
resource "aws_ecs_task_definition" "game_task" {
  family                   = "${var.cluster_name}-task"
  requires_compatibilities  = ["FARGATE"]
  network_mode              = "awsvpc"
  cpu                       = "256"
  memory                    = "512"
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "node-shooter-game"
      image     = "${var.ecr_repo_url}:latest"
      essential = true
      portMappings = [
        { containerPort = 3000, hostPort = 3000 }
      ]
      environment = [
        { name = "DB_HOST", value = var.db_endpoint },
        { name = "DB_USER", value = var.db_username },
        { name = "DB_PASS", value = var.db_password },
        { name = "DB_NAME", value = var.db_name }
      ]
    }
  ])

  tags = {
    Name = "${var.cluster_name}-task"
  }
}

# ------------------------
# ECS Service
# ------------------------
resource "aws_ecs_service" "game_service" {
  name            = "${var.cluster_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.game_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "node-shooter-game"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.ecs_listener]
}
