output "user_pool_id" {
  value       = aws_cognito_user_pool.this.id
  description = "Cognito User Pool ID"
}

output "user_pool_client_id" {
  value = var.client_name != null ? (
    var.enable_google_idp && length(aws_cognito_user_pool_client.google) > 0 ? aws_cognito_user_pool_client.google[0].id : (
      length(aws_cognito_user_pool_client.this) > 0 ? aws_cognito_user_pool_client.this[0].id : null
    )
    ) : (
    length(var.clients) > 0 ? try(
      aws_cognito_user_pool_client.clients[var.clients[0].name].id,
      null
    )
    : null
  )
  description = "Cognito User Pool Client ID (DEPRECATED - kept for backward compatibility; prefer `user_pool_client_ids`)"
}

output "user_pool_client_ids" {
  value = merge(
    # Default client (when not using Google IDP and client_name is provided)
    (var.client_name != null && !var.enable_google_idp && length(aws_cognito_user_pool_client.this) > 0) ? { (var.client_name) = aws_cognito_user_pool_client.this[0].id } : {},
    # Google client (when using Google IDP and client_name is provided)
    (var.client_name != null && var.enable_google_idp && length(aws_cognito_user_pool_client.google) > 0) ? { ("${var.client_name}-google") = aws_cognito_user_pool_client.google[0].id } : {},
    # Clients
    { for name, client in aws_cognito_user_pool_client.clients : name => client.id }
  )
  description = "Map of all Cognito User Pool Client IDs (name -> client_id)"
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
  value       = length(aws_cognito_user_pool_domain.this) > 0 ? aws_cognito_user_pool_domain.this[0].domain : null
  description = "Cognito Hosted UI domain prefix (only when Google IDP and domain prefix are configured)"
}

# output "user_pool_domain" {
#   value       = aws_cognito_user_pool_domain.cognito_user_pool_domain.domain
#   description = "Cognito User Pool Domain"
# }
