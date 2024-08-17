resource "aws_s3_bucket" "qcp_configs" {
  bucket = "qcp-configs-${var.environment}"
  tags = {
    Name = "qcp-configs"
  }
}

resource "aws_s3_bucket_versioning" "qcp_configs" {
  bucket = aws_s3_bucket.qcp_configs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "qcp_configs" {
  bucket = aws_s3_bucket.qcp_configs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "qcp_configs" {
  depends_on = [aws_s3_bucket_ownership_controls.qcp_configs]
  bucket     = aws_s3_bucket.qcp_configs.id
  acl        = "private"
}

resource "aws_s3_bucket" "qcp_configs_log_bucket" {
  bucket = "qcp-configs-logs-${var.environment}"
  tags = {
    Name = "qcp-configs-logs"
  }
}

resource "aws_s3_bucket_ownership_controls" "qcp_configs_log_bucket" {
  bucket = aws_s3_bucket.qcp_configs_log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "qcp_configs_log_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.qcp_configs_log_bucket]
  bucket     = aws_s3_bucket.qcp_configs_log_bucket.id
  acl        = "log-delivery-write"
}
resource "aws_s3_bucket_logging" "qcp_configs" {
  bucket        = aws_s3_bucket.qcp_configs.id
  target_bucket = aws_s3_bucket.qcp_configs_log_bucket.id
  target_prefix = "log/"
}
