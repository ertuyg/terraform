resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.origin_access_control_name
  description                       = "Allow CloudFront access to the S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

# eğer s3 bucket oluşturulmamışsa
# resource "aws_s3_bucket" "this" {
#   bucket = var.bucket_name
# }


resource "aws_s3_bucket_policy" "cdn-oac-bucket-policy" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.this.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  #TODO: originleri variablelerden alacak bir yapıı kurmalı
  origin {
    domain_name              = data.aws_s3_bucket.this.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
    origin_id                = var.s3_origin_id
    #origin_path              = "/images" #bu path bucket içerisindeki path yani eğer bunu koyarsan bucket içindeki images klasörüne /images yazmadan erişebilirsin
  }

  enabled         = true
  is_ipv6_enabled = true
  #   comment             = "Some comment"
  #   default_root_object = "index.html"

  #   logging_config {
  #     include_cookies = false
  #     bucket          = "mylogs.s3.amazonaws.com"
  #     prefix          = "myprefix"
  #   }

  aliases = var.aliases

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id

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


  #TODO: cache behaviorları variablelerden alacak bir yapıı kurmalı
  ordered_cache_behavior {
    path_pattern     = "/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  #   price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      #   locations        = []
    }
  }

  tags = {
    Environment = var.Environment
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
