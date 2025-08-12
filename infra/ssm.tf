resource "aws_ssm_parameter" "db_username" {
  name  = "/${var.project_name}/db_username"
  type  = "String"
  value = var.db_username
  overwrite = true
}
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/db_password"
  type  = "SecureString"
  value = var.db_password
  overwrite = true
}
resource "aws_ssm_parameter" "db_name" {
  name  = "/${var.project_name}/db_name"
  type  = "String"
  value = var.db_name
  overwrite = true
}