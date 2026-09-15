resource "aws_kms_key" "pedidos_export" {
  description             = "CMK para cifrar el bucket de exportacion de pedidos"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_s3_bucket" "pedidos_export" {
  bucket = "plataforma-pedidos-export"
}

resource "aws_s3_bucket_versioning" "pedidos_export" {
  bucket = aws_s3_bucket.pedidos_export.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pedidos_export" {
  bucket = aws_s3_bucket.pedidos_export.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.pedidos_export.arn
    }
  }
}

resource "aws_s3_bucket_logging" "pedidos_export" {
  bucket        = aws_s3_bucket.pedidos_export.id
  target_bucket = aws_s3_bucket.pedidos_export.id
  target_prefix = "log/"
}

resource "aws_s3_bucket_public_access_block" "pedidos_export" {
  bucket                  = aws_s3_bucket.pedidos_export.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_security_group" "pedidos_api_sg" {
  name        = "sg-plataforma-pedidos-api"
  description = "Acceso a la API de pedidos"

  ingress {
    description = "SSH de administracion, solo desde la VPN corporativa"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}
