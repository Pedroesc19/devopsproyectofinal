resource "aws_ecs_cluster" "this" {
  name         = "${var.project_name}-cluster"
  force_delete = true
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

locals {
  container_name = "${var.project_name}-web"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 0.5 GB
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name         = local.container_name,
      image        = var.image_uri,
      essential    = true,
      portMappings = [{ containerPort = 80, hostPort = 80, protocol = "tcp" }],
      environment = [
        { name = "DB_HOST", value = aws_db_instance.mysql.address }
      ],
      secrets = [
        { name = "DB_USERNAME", valueFrom = aws_ssm_parameter.db_username.arn },
        { name = "DB_PASSWORD", valueFrom = aws_ssm_parameter.db_password.arn },
        { name = "DB_NAME", valueFrom = aws_ssm_parameter.db_name.arn }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "${var.project_name}-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  force_delete    = true

  network_configuration {
    subnets          = [for s in aws_subnet.public : s.id]
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = true
  }
}
