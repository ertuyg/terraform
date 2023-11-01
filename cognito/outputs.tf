output "user_pool_id" {
  value       = aws_cognito_user_pool.this.id
  description = "Cognito User Pool ID"
}

output "user_pool_arn" {
  value       = aws_cognito_user_pool.this.arn
  description = "Cognito User Pool ARN"
}


output "user_pool_issuer" {
  value       = aws_cognito_user_pool.this.endpoint
  description = "Cognito User Pool Issuer"
}

output "admin_policy_arn" {
  description = "ARNs of the created DynamoDB tables"
  value       = aws_iam_policy.admin_policy.arn
}

# output "user_pool_domain" {
#   value       = aws_cognito_user_pool_domain.cognito_user_pool_domain.domain
#   description = "Cognito User Pool Domain"
# }
