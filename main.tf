terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
# TODO: Generate terraform profile manually in the credentials file
provider "aws" {
  region                   = "ap-southeast-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "terraform"
}

resource "aws_s3_bucket" "s3-bucket" {
  bucket = "simple-blog"
}

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.s3-bucket.id
  key = "index.html"
  source = "index.html"
  content_type = "text/html"
}

resource "aws_cloudfront_origin_access_control" "cf-s3-oac" {
  name = "cf-s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.s3-bucket.id
  policy = data.aws_iam_policy_document.allow-cloudfront-get.json
}

data "aws_iam_policy_document" "allow-cloudfront-get" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.s3-bucket.bucket}/*"
    ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = ["${aws_cloudfront_distribution.CF-distribution.arn}"]
    }

  }
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "CF-distribution" {
  origin {
    domain_name              = aws_s3_bucket.s3-bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.cf-s3-oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
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

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
}