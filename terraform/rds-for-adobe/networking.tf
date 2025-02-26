data "aws_vpc" "default" {
  id = var.vpc_id
}

data "aws_subnet" "subnet_b" {
  id = var.subnet_id_b
}

data "aws_subnet" "subnet_c" {
  id = var.subnet_id_c
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "adobe-aurora-subnet-group"
  subnet_ids = [data.aws_subnet.subnet_b.id, data.aws_subnet.subnet_c.id]
}