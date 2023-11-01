
# output "table_name" {
#   description = "Names of the created DynamoDB tables"
#   value       = aws_dynamodb_table.this.name

# }

# output "table_arn" {
#   description = "ARNs of the created DynamoDB tables"
#   value       = aws_dynamodb_table.this.arn
# }

output "readonly_policy_arn" {
  description = "ARNs of the created DynamoDB tables"
  value       = aws_iam_policy.readonly.arn
}

output "readwrite_policy_arn" {
  description = "ARNs of the created DynamoDB tables"
  value       = aws_iam_policy.readwrite.arn
}
