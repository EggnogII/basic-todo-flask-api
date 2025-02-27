output "cluster_endpoint" {
  value = aws_rds_cluster.aurora_postgres_cluster.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.aurora_postgres_cluster.reader_endpoint
}

output "instance_endpoint" {
  value = aws_rds_cluster_instance.aurora_postgres_instance.*.endpoint
}