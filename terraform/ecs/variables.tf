variable "cluster_name" {}
variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "ecr_repo_url" {}
variable "db_endpoint" {}
variable "db_username" {}
variable "db_password" {}
variable "db_name" {}
