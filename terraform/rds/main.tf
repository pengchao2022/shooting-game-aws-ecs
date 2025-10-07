resource "aws_db_subnet_group" "this" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.subnets
}

resource "aws_db_instance" "this" {
  identifier              = "${var.db_name}-instance"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = "db.t3.micro"
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.security_group_id]
  skip_final_snapshot     = true
  publicly_accessible     = false
}
