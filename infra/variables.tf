variable "project_name" { type = string }
variable "region" { type = string }

# CIDRs mínimos (ajusta si quieres)
variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

# Imagen a desplegar (se sobreescribe desde el pipeline)
variable "image_uri" {
  type    = string
  default = "public.ecr.aws/docker/library/nginx:latest"
}

# RDS (usar clases Free Tier p.ej. db.t3.micro)
variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "db_name" {
  type    = string
  default = "appdb"
}
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}

# OIDC GitHub (opcional)
variable "enable_github_oidc" {
  type    = bool
  default = false
}
variable "github_repo" {
  type    = string
  default = null
} # formato: owner/repo
variable "aws_account_id" {
  type    = string
  default = null
}