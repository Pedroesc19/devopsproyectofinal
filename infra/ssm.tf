resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.project_name}/db_username"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/db_password"
  type  = "SecureString"
  value = var.db_password
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project_name}/db_name"
  type  = "String"
  value = var.db_name
}