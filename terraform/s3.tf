##################
# Create S3 bucket
##################
resource "aws_s3_bucket" "fugaming_org" {
  bucket = "${var.environment}.fugaming.org"
  acl = "private"

  lifecycle {
    prevent_destroy = true
  }

}

# Enable object versioning
resource "aws_s3_bucket_versioning" "static_assets_versioning" {
  bucket = aws_s3_bucket.fugaming_org.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "static_assets_encryption" {
  bucket = aws_s3_bucket.fugaming_org.id

    rule {
        bucket_key_enabled = true

        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

data "aws_iam_policy_document" "fugaming_s3_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.fugaming_org.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.fugaming_org.arn}"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "fugaming_s3_policy" {
  bucket = "${aws_s3_bucket.fugaming_org.id}"
  policy = "${data.aws_iam_policy_document.fugaming_s3_policy_document.json}"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
}

###########################
# Create an ACM certificate
###########################
resource "aws_acm_certificate" "cert" {
  domain_name       = "fugaming.org"
  validation_method = "DNS"
  provider = "us_east_1"
  lifecycle {
    create_before_destroy = true
  }
}
output "acm_dns_validation" {
  value = "${aws_acm_certificate.cert.domain_validation_options}"
}

###########################
# Create a CloudFront distribution
###########################
resource "aws_cloudfront_distribution" "fugaming_cf" {
  origin {
    domain_name = "${aws_s3_bucket.fugaming_org.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = ["fugaming.org"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    compress = true
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate.cert.arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}