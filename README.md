# Proyecto Final DevOps: AWS + Terraform + GitHub Actions

## Arquitectura

- **Flask** en contenedor Docker
- **ECR** para imágenes
- **ECS Fargate** ejecuta el contenedor (0.25 vCPU / 0.5 GB)
- **RDS MySQL** (db.t3.micro) con parámetros expuestos a la tarea via **SSM Parameter Store**
- **VPC** con 2 subredes públicas + IGW
- **Security Groups**: HTTP público a la app, MySQL restringido desde la app
- **CI/CD** con GitHub Actions: build & push, deploy Terraform

> ⚠️ Costos: Intenta ceñirte al Free Tier (RDS db.t3.micro, almacenamiento mínimo). ECS Fargate no siempre entra en Free Tier; usa los tamaños mínimos y apaga recursos cuando no los uses. El balanceador NO se usa para evitar costos.

## Prerrequisitos locales

- VS Code, Docker, Terraform >= 1.6, AWS CLI v2, cuenta AWS, GitHub repo

## Paso a paso

1. **Clona** este repo en tu GitHub y en VS Code.
2. Copia `infra/terraform.tfvars.example` a `infra/terraform.tfvars` y ajusta:
   ```hcl
   project_name = "demo-devops"
   region       = "us-east-1"
   db_username  = "appuser"
   db_password  = "<seguro>"
   db_name      = "appdb"
   ```
