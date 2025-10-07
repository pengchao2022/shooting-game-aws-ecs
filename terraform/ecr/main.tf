resource "aws_ecr_repository" "backend" {
  name                 = var.repo_backend_name
  image_tag_mutability = "MUTABLE"
  tags = { Name = var.repo_backend_name }
}

resource "aws_ecr_repository" "frontend" {
  name                 = var.repo_frontend_name
  image_tag_mutability = "MUTABLE"
  tags = { Name = var.repo_frontend_name }
}
