data "aws_db_instance" "aurora_postgres_instance" {
    db_instance_identifier = var.rds_instance
}
