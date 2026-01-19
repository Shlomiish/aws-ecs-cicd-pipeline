# ------ CLOUDFRONT ORIGIN ACCESS CONTROL (S3 PRIVATE ACCESS) ------

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.name}-oac"
  description                       = "OAC for S3 origin" #OAC (origin access control (old - OAI)) type for permission to S3  
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always" # only sign requests to S3
  signing_protocol                  = "sigv4"
}

# ------ CLOUDFRONT DISTRIBUTION (S3 CLIENT + ALB API) ------

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  default_root_object = "index.html"

  # ------ ORIGINS ------

  origin {
    domain_name              = var.bucket_regional_domain_name
    origin_id                = "s3-client" #the id inside the cloudfront distribution (for knowing where to send the data)
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb-api"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  # ------ PATH-BASED ROUTING ------

  # Default behavior -> S3 (client)
  default_cache_behavior {
    target_origin_id       = "s3-client"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    compress         = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }
  }

  # /api/* -> ALB (server)
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "alb-api"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]
    compress        = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }

      headers = ["Authorization", "Origin"]
    }
  }

  # ------ GEO RESTRICTIONS ------

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # ------ TLS CERTIFICATE ------

  viewer_certificate {
    cloudfront_default_certificate = true # Uses *.cloudfront.net certificate (no custom domain)
  }
}

# ------ S3 BUCKET POLICY (ALLOW CLOUDFRONT OAC) ------

# S3 bucket policy to allow CloudFront OAC
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid     = "AllowCloudFrontServicePrincipalReadOnly"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = [
      "${var.bucket_arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.this.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.bucket_policy.json
}
