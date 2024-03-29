resource "aws_s3_bucket" "waf_traffic_log_bucket" {
  bucket = "aws-waf-logs--${var.name_prefix}"

  tags = {
    Name = "${var.tag_name}-waf-traffic-log"
    group = "${var.tag_group}"
  }
}

resource "aws_s3_bucket_public_access_block" "waf_traffic_log_bucket_public_access_block" {
  bucket = aws_s3_bucket.waf_traffic_log_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "waf_traffic_log_bucket_policy_document" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.waf_traffic_log_bucket.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
  statement {
    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.waf_traffic_log_bucket.arn
    ]

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "waf_traffic_log_bucket_policy" {
  bucket = aws_s3_bucket.waf_traffic_log_bucket.id
  policy = data.aws_iam_policy_document.waf_traffic_log_bucket_policy_document.json
}

resource "aws_s3_bucket_lifecycle_configuration" "waf_traffic_log_bucket_lifecycle_configuration" {
  bucket = aws_s3_bucket.waf_traffic_log_bucket.id

  rule {
    id     = "transfer to glacier"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }

}

# アクセスログの送信先を定義
resource "aws_s3_bucket_logging" "waf_traffic_log_bucket_logging" {
  bucket        = aws_s3_bucket.waf_traffic_log_bucket.id
  target_bucket = aws_s3_bucket.waft_traffic_log_bucket_bclg.id
  target_prefix = "waf-traffic-log-bclg"
}