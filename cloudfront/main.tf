locals {
  # Determine if using legacy single-origin or new multi-origin setup
  use_legacy_mode = length(var.origins) == 0

  # Build origins map for iteration
  origins_map = local.use_legacy_mode ? {
    (var.s3_origin_id) = {
      bucket_name                = var.bucket_name
      origin_id                  = var.s3_origin_id
      origin_path                = ""
      origin_access_control_name = var.origin_access_control_name
      origin_access_control_id   = null
    }
  } : { for origin in var.origins : origin.origin_id => origin }

  # Build OAC map - only create OAC if ID is not provided
  oac_to_create = {
    for origin_id, origin in local.origins_map :
    origin_id => {
      name        = coalesce(origin.origin_access_control_name, "${origin_id}-oac")
      bucket_name = origin.bucket_name
    }
    if origin.origin_access_control_id == null
  }
}

resource "aws_cloudfront_origin_access_control" "this" {
  for_each = local.oac_to_create

  name                              = each.value.name
  description                       = "Allow CloudFront access to S3 bucket ${each.value.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_s3_bucket" "this" {
  for_each = local.origins_map

  bucket = each.value.bucket_name
}

resource "aws_s3_bucket_policy" "cdn-oac-bucket-policy" {
  for_each = local.origins_map

  bucket = each.value.bucket_name
  policy = data.aws_iam_policy_document.s3_bucket_policy[each.key].json
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  for_each = local.origins_map

  statement {
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.this[each.key].arn}/*"]
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
  dynamic "origin" {
    for_each = local.origins_map

    content {
      domain_name              = data.aws_s3_bucket.this[origin.key].bucket_regional_domain_name
      origin_id                = origin.value.origin_id
      origin_path              = origin.value.origin_path
      origin_access_control_id = origin.value.origin_access_control_id != null ? origin.value.origin_access_control_id : aws_cloudfront_origin_access_control.this[origin.key].id
    }
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
    target_origin_id = local.use_legacy_mode ? var.s3_origin_id : var.origins[0].origin_id

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


  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behaviors

    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = ordered_cache_behavior.value.allowed_methods
      cached_methods   = ordered_cache_behavior.value.cached_methods
      target_origin_id = ordered_cache_behavior.value.target_origin_id
      compress         = ordered_cache_behavior.value.compress

      forwarded_values {
        query_string = ordered_cache_behavior.value.query_string

        cookies {
          forward = ordered_cache_behavior.value.cookies_forward
        }
      }

      min_ttl                = ordered_cache_behavior.value.min_ttl
      default_ttl            = ordered_cache_behavior.value.default_ttl
      max_ttl                = ordered_cache_behavior.value.max_ttl
      viewer_protocol_policy = ordered_cache_behavior.value.viewer_protocol_policy
    }
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
