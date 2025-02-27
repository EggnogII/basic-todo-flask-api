provider "aws" {
  region = "us-west-1"
}

resource "aws_rds_cluster" "aurora_postgres_cluster" {
  cluster_identifier  = "adobe-aurora-postgres-cluster"
  engine              = "aurora-postgresql"
  engine_version      = "16.4"
  database_name       = var.db_name
  master_username     = var.db_user
  master_password     = var.rds_cluster_password
  skip_final_snapshot = true

  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
}

resource "aws_rds_cluster_instance" "aurora_postgres_instance" {
  count                = 1
  identifier           = "adobe-aurora-postgres-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.aurora_postgres_cluster.id
  instance_class       = var.instance_type
  engine               = aws_rds_cluster.aurora_postgres_cluster.engine
  engine_version       = aws_rds_cluster.aurora_postgres_cluster.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
}