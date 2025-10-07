variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "subnets" {
  description = "Private subnet IDs for RDS"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for RDS"
  type        = string
}
