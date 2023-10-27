# output "dynamodb_table_arn" {
#   description = "The ARN of the DynamoDB table."
#   value       = aws_dynamodb_table.dynamodb_table.arn
# }

# output "dynamodb_table_id" {
#   description = "The name of the DynamoDB table."
#   value       = aws_dynamodb_table.dynamodb_table.id
# }

output "dynamodb_table_names" {
  description = "Names of the created DynamoDB tables"
  value       = { for table_name, table in aws_dynamodb_table.dynamodb_table : table_name => table.name }

}

output "dynamodb_table_arns" {
  description = "ARNs of the created DynamoDB tables"
  value       = { for table_name, table in aws_dynamodb_table.dynamodb_table : table_name => table.arn }
}


# output "modify_policies" {
#   value       = { for table in var.tables : table.table_name => aws_iam_policy.modify[table.table_name].name }
#   description = "ARNs of the modify policies for each table"
# }

# output "readonly_policies" {
#   value       = { for table in var.tables : table.table_name => aws_iam_policy.readonly[table.table_name].name }
#   description = "ARNs of the readonly policies for each table"
# }

output "modify_policies" {
  value       = { for table in var.tables : table.table_name => aws_iam_policy.modify[table.table_name].arn }
  description = "ARNs of the modify policies for each table"
}

output "readonly_policies" {
  value       = { for table in var.tables : table.table_name => aws_iam_policy.readonly[table.table_name].arn }
  description = "ARNs of the readonly policies for each table"
}
