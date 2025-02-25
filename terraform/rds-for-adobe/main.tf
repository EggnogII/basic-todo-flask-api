provider "aws"{
    region = "us-west-1"
}


data "aws_vpc" "default" {
    id = "vpc-096851120f324fbf5" # Put your main VPC ID here
}

data "aws_subnet" "subnet_b" {
  id = "subnet-071a616244276d1ad" # Put your subnet ID here
}

data "aws_subnet" "subnet_c" {
  id = "subnet-0423370b6425be19c" # Put your subnet ID here
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
    name = "my-aurora-subnet-group"
    subnet_ids = [data.aws_subnet.subnet_b.id, data.aws_subnet.subnet_c.id]
}

resource "aws_security_group" "aurora_sg"{
    name = "aurora-sg"
    description = "Allow inbound PostgresSQL traffic"
    vpc_id = data.aws_vpc.default.id

    ingress {
        from_port = 5432
        to_port = 5432
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

resource "aws_rds_cluster" "aurora_postgres_cluster" {
    cluster_identifier = "adobe-aurora-postgres-cluster"
    engine = "aurora-postgresql"
    engine_version = "16.4"
    database_name = "adobe"
    master_username = "postgres_adobe"
    master_password = var.rds_cluster_password
    skip_final_snapshot = true

    backup_retention_period = 5
    preferred_backup_window = "07:00-09:00"
    vpc_security_group_ids = [aws_security_group.aurora_sg.id]
    db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
}

resource "aws_rds_cluster_instance" "aurora_postgres_instance" {
    count = 1
    identifier = "adobe-aurora-postgres-instance-${count.index}"
    cluster_identifier = aws_rds_cluster.aurora_postgres_cluster.id
    instance_class = "db.r7i.large" # For some reason the smaller instances don't support Postgres
    engine = aws_rds_cluster.aurora_postgres_cluster.engine
    engine_version = aws_rds_cluster.aurora_postgres_cluster.engine_version
    publicly_accessible = false
    db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
}