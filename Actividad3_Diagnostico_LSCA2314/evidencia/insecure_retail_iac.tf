resource "aws_db_instance" "pagos_retail_db" {
  identifier             = "pagos-retail-db"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = "admin_pagos"
  password               = "Retail2026!"
  publicly_accessible    = true
  storage_encrypted      = false
  skip_final_snapshot    = true
}

resource "aws_security_group" "pagos_retail_db_sg" {
  name = "sg-pagos-retail-db"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

