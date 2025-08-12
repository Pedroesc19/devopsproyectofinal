output "ecr_repository_url" { value = aws_ecr_repository.app.repository_url }
output "rds_endpoint" { value = aws_db_instance.mysql.address }
output "ecs_cluster" { value = aws_ecs_cluster.this.name }
output "ecs_service" { value = aws_ecs_service.app.name }
output "region" { value = var.region }