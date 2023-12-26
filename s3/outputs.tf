output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "website_endpoint" {
  description = "The website endpoint of the S3 bucket"
  value       = var.enable_website ? aws_s3_bucket_website_configuration.this[0].website_endpoint : null
}

output "bucket_policy_arn" {
  description = "The ARN of the S3 bucket policy"
  value       = var.access_lambda ? aws_iam_policy.lambda_s3_policy[0].arn : null
}
