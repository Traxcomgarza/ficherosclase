resource "aws_s3_bucket" "catalogo_retail" {
  bucket = "catalogo-retail-imagenes"
  acl    = "public-read"
}

resource "aws_security_group" "catalogo_retail_sg" {
  name = "sg-catalogo-retail"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "catalogo_retail_db" {
  identifier          = "catalogo-retail-db"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_encrypted   = false
  username            = "admin"
  password            = "RetailAdmin2026"
  skip_final_snapshot = true
}
