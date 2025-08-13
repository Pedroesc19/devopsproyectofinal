# Proyecto: App Python + Terraform + GitHub Actions

> README breve y accionable. Incluye arquitectura, estructura del repo, pasos de ejecución y marcadores para capturas.

## 1) Descripción

Aplicación **Python (Flask)** con frontend **HTML**; infraestructura en **AWS** definida con **Terraform**; CI/CD con **GitHub Actions** para construir la imagen, publicarla en ECR y desplegar a ECS/Fargate.

## 2) Arquitectura (resumen)

- **App**: Flask + HTML, contenedor Docker.
- **Infra (Terraform)**: VPC mínima, ECS (Fargate), ECR, RDS MySQL (opcional), SGs.
- **CI/CD (GitHub Actions)**: Workflows para `terraform apply` y para _build & push_ de imagen → `ecs update-service`.

```
[Dev] ──push──> [GitHub Actions] ───────> [AWS]
                 |  Terraform Apply        ├─ ECR (imagen)
                 |  Build & Push Docker    ├─ ECS/Fargate (servicio)
                 └─ Update Service         └─ (RDS opcional)
```

## 3) Estructura del proyecto

```
.
├─ app/                    # Código Python (Flask) + templates HTML
│  ├─ app.py
│  ├─ requirements.txt
│  └─ templates/
├─ infra/                  # Terraform (ECR, ECS, VPC, RDS opcional)
│  ├─ main.tf
│  ├─ variables.tf
│  ├─ outputs.tf
│  └─ terraform.tfvars.example
├─ .github/
│  └─ workflows/
│     ├─ terraform_deploy.yml    # Plan/Apply/Destroy (según evento)
│     └─ build_and_deploy.yml    # Build Docker → Push ECR → Update ECS
├─ scripts/
│  ├─ get_service_public_ip.sh   # Obtener IP pública de la tarea ECS
│  └─ get_service_public_ip.ps1
└─ README.md
```

## 4) Prerrequisitos

- Cuenta **AWS**, **AWS CLI v2**, **Terraform ≥ 1.6**, **Docker**.
- Repositorio en **GitHub** con **Actions** habilitado.

## 5) Configuración rápida

1. **Fork/clone** del repo.
2. Copia `infra/terraform.tfvars.example` → `infra/terraform.tfvars` y ajusta:
   ```hcl
   project_name = "demo-devops"
   region       = "us-east-1"
   db_username  = "appuser"      # opcional si usas RDS
   db_password  = "<segura>"
   db_name      = "appdb"
   ```
3. En **GitHub → Settings → Secrets and variables**:
   - **Secrets**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `DB_USERNAME`, `DB_PASSWORD` (si RDS).
   - **Variables**: `AWS_ACCOUNT_ID`, `AWS_REGION`, `PROJECT_NAME`, `DB_NAME`.

## 6) Despliegue con GitHub Actions

**A. Infra** (Terraform):

1. Haz _commit/push_ de `infra/terraform.tfvars` a `main` **o** ejecuta manualmente el workflow **Terraform Deploy** en _Actions_.
2. Espera estado **success**.

**B. App (Build & Deploy)**:

1. Haz _push_ de cambios en `app/` a `main`.
2. El workflow **Build & Deploy**: construye imagen → _push_ a **ECR** → `ecs update-service`.

**C. Obtener URL**:

- Ejecuta script:
  ```bash
  ./scripts/get_service_public_ip.sh <cluster> <servicio> [region]
  ```
  o revisa la IP pública de la tarea en **AWS ECS**.

## 7) Verificación rápida

- Navega a: `http://<IP_PUBLICA>/` → **deberías ver la página HTML**.
- Salud API: `http://<IP_PUBLICA>/healthz`.

## 8) Marcadores de **capturas de pantalla**

> Coloca las imágenes en `images/` y actualiza las rutas debajo.

1. **Página web funcionando** (tras _Build & Deploy_ e IP lista):
   ![App corriendo](images/app_running.png)
   _Figura 1: Página principal Flask en el navegador._

2. **Workflow exitoso en GitHub Actions** (al finalizar cada job):
   ![Actions success](images/gh_actions_success.png)
   _Figura 2: Ejecución exitosa de Terraform/Build & Deploy._

3. **Servicio ECS en ejecución** (consola AWS → ECS → Service/Tareas):
   ![ECS running](images/ecs_service_running.png)
   _Figura 3: Tarea Fargate en estado RUNNING._

## 9) Ejecución local (opcional)

```bash
cd app
python -m venv .venv && source .venv/bin/activate   # en Windows: .venv\Scripts\activate
pip install -r requirements.txt
flask --app app.py run -h 0.0.0.0 -p 5000
```

Abrir: `http://localhost:5000`

## 10) Limpieza (opcional)

- Ejecuta **Terraform Destroy** desde el workflow correspondiente en _Actions_ **o** corre `terraform destroy` en `infra/`.

---
