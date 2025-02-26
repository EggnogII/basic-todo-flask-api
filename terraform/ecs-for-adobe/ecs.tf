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
    role = aws_iam_role.adobe_flask_ecs_iam_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_ecs_task_definition" "adobe_flask_ecs_task_definition" {
    family = "adobe-flask"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = 1024
    memory = 2048
    execution_role_arn = aws_iam_role.adobe_flask_ecs_iam_role.arn

    container_definitions = jsonencode([
        {
            name = "adobe-flask"
            image = "887712174622.dkr.ecr.us-west-1.amazonaws.com/eggnog-docker:adobe-flask-web-api-857e03a76d2b06ace7fd15e076ea197c88de3fd8" # Change to var later
            essential = true
            environment = [
                {
                    name = "DB_HOST"
                    value = "adobe-aurora-postgres-instance-0.czweoiicy1o6.us-west-1.rds.amazonaws.com" # Change to var later
                },
                {
                    name = "DB_NAME"
                    value = "adobe" # Change to var later
                },
                {
                    name = "DB_USER"
                    value = "postgres_adobe"
                },
                {
                    name = "DB_PASSWORD"
                    value = var.rds_cluster_password
                }
            ]
            log_configuration = {
                logDriver = "awslogs"
                options = {
                    awslogs-group = "/ecs/adobe-flask"
                    awslogs-region = "us-west-1"
                    awslogs-stream-prefix = "ecs"
                }
            }
        }
    ])
}

resource "aws_ecs_service" "adobe_flask_ecs_service" {
    name = "adobe-flask-ecs-service"
    cluster = aws_ecs_cluster.adobe_flask_ecs_cluster.id
    task_definition = aws_ecs_task_definition.adobe_flask_ecs_task_definition.arn
    desired_count = 1
    launch_type = "FARGATE"

    network_configuration {
        subnets = ["subnet-071a616244276d1ad", "subnet-0423370b6425be19c"]
        security_groups =[""]
    }
}