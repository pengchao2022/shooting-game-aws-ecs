# ECR Repository for Frontend
resource "aws_ecr_repository" "frontend" {
  name = "${var.project_name}-frontend"

  # Lifecycle rules to prevent accidental destruction and ignore changes to specific attributes
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [image_tag_mutability]
  }

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-frontend"
  }
}

# ECR Repository for Backend
resource "aws_ecr_repository" "backend" {
  name = "${var.project_name}-backend"

  # Lifecycle rules to prevent accidental destruction and ignore changes to specific attributes
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [image_tag_mutability]
  }

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-backend"
  }
}
