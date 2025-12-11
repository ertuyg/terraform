output "user_pool_id" {
  value       = aws_cognito_user_pool.this.id
  description = "Cognito User Pool ID"
}

output "user_pool_client_id" {
  value       = var.enable_google_idp ? aws_cognito_user_pool_client.google[0].id : aws_cognito_user_pool_client.this[0].id
  description = "Cognito User Pool Client ID"
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
  description = "ARN of the Cognito admin IAM policy"
  value       = aws_iam_policy.admin_policy.arn
}

output "cognito_domain" {
  value       = var.enable_google_idp && var.cognito_domain_prefix != null ? aws_cognito_user_pool_domain.this[0].domain : null
  description = "Cognito Hosted UI domain prefix (only when Google IDP and domain prefix are configured)"
}

# output "user_pool_domain" {
#   value       = aws_cognito_user_pool_domain.cognito_user_pool_domain.domain
#   description = "Cognito User Pool Domain"
# }
