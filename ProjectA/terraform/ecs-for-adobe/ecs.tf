resource "aws_ecs_cluster" "adobe_flask_ecs_cluster" {
  name = "adobe-flask-ecs-cluster"
}

resource "aws_iam_role" "adobe_flask_ecs_iam_role" {
  name = "adobe-flask-ecs-iam-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "adobe_flask_ecs_iam_role_policy_attachment" {
  role       = aws_iam_role.adobe_flask_ecs_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "adobe_flask_ecs_task_definition" {
  family                   = "adobe-flask"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = aws_iam_role.adobe_flask_ecs_iam_role.arn

  container_definitions = jsonencode([
    {
      name      = "adobe-flask"
      image     = var.ecr_image_uri
      cpu       = 2048
      memory    = 4096
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        {
          name  = "DB_HOST"
          value = data.aws_db_instance.aurora_postgres_instance.endpoint
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_user
        },
        {
          name  = "DB_PASSWORD"
          value = var.rds_cluster_password
        }
      ]
      log_configuration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/adobe-flask"
          awslogs-region        = "us-west-1"
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        "command" : ["CMD-SHELL", "curl -f http://localhost:80/health || exit 1"],
        "interval" : 30,
        "timeout" : 10,
        "retries" : 3,
        "startPeriod" : 30
      }
    }
  ])
}

resource "aws_ecs_service" "adobe_flask_ecs_service" {
  name            = "adobe-flask-ecs-service"
  cluster         = aws_ecs_cluster.adobe_flask_ecs_cluster.id
  task_definition = aws_ecs_task_definition.adobe_flask_ecs_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.subnet_id_b, var.subnet_id_c]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.adobe_flask_tg.arn
    container_name   = "adobe-flask"
    container_port   = 80
  }
}

resource "aws_cloudwatch_log_group" "adobe_flask_log_group" {
  name              = "/ecs/adobe-flask"
  retention_in_days = 7
}
