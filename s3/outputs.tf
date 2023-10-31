output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.this.bucket
}

output "s3_bucket_website_endpoint" {
  description = "The website endpoint of the S3 bucket"
  value       = var.enable_website ? aws_s3_bucket_website_configuration.this[0].website_endpoint : null
}

# output "s3_bucket_policy" {
#   description = "The S3 bucket policy"
#   value       = var.enable_website ? aws_s3_bucket_policy.this[0].json : null
# }

# output "s3_bucket_ownership_controls" {
#   description = "The S3 bucket ownership controls"
#   value       = var.enable_website ? aws_s3_bucket_ownership_controls.this[0].rule[0].object_ownership : null
# }

# output "s3_bucket_public_access_block" {
#   description = "The S3 bucket public access block settings"
#   value = var.enable_website ? {
#     block_public_acls       = aws_s3_bucket_public_access_block.this[0].block_public_acls
#     block_public_policy     = aws_s3_bucket_public_access_block.this[0].block_public_policy
#     ignore_public_acls      = aws_s3_bucket_public_access_block.this[0].ignore_public_acls
#     restrict_public_buckets = aws_s3_bucket_public_access_block.this[0].restrict_public_buckets
#   } : null
# }

# output "s3_bucket_acl" {
#   description = "The S3 bucket ACL"
#   value       = var.enable_website ? aws_s3_bucket_acl.this[0].acl : null
# }
