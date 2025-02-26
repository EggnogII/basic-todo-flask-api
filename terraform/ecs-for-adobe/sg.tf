resource "aws_security_group" "ecs_sg" {
    name = "ecs-sg"
    description = "Allow ECS tasks to comminicate with RDS"
    vpc_id = "vpc-096851120f324fbf5" # Change to var later

    ingress {
        from_port = 80
        to_port = 80
        protocol = "-1"
        security_groups = [aws_security_group.alb_sg.id]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "rds_sg" {
    name = "rds-sg"
    description = "Allow ECS tasks to access RDS"
    vpc_id = "vpc-096851120f324fbf5"

    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        security_groups = [aws_security_group.ecs_sg.id]
    }
}

resource "aws_security_group" "alb_sg" {
    name = "alb-sg"
    description = "Allow inbound HTTP traffic"
    vpc_id = "vpc-096851120f324fbf5"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}