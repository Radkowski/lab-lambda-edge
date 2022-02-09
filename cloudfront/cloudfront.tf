data "aws_s3_bucket" "s3-bucket" {
  bucket = var.bucketname
}


locals {
  s3_origin_id = join("", [var.DeploymentName, "-origin"])
}


resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = join("", [var.DeploymentName, "-OAI"])
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = data.aws_s3_bucket.s3-bucket.bucket_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = join("", [var.DeploymentName, "-dist"])
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = var.lambdaedgeurl
      include_body = false
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }
  tags = {
    Environment = "production"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


output "oaiid" {
  value = aws_cloudfront_origin_access_identity.origin_access_identity.id
}
