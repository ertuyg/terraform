output "my_api_url" {
  description = "The URL of my API."
  value       = module.apigateway.api_endpoint
}

# output "table_arns" {
#   description = "ARNs of the DynamoDB tables"
#   value       = [for i in module.dynamodb : i.table_arn]
# }

# output "readonly_policies" {
#   value = [for i in module.dynamodb : i.readonly_policy]
# }
# output "readwrite_policies" {
#   value = [for i in module.dynamodb : i.readwrite_policy]
# }

# output "dynamodb_table_arns" {
#   description = "ARNs of the created DynamoDB tables"
#   value       = { for table_name, table in aws_dynamodb_table.dynamodb_table : table_name => table.arn }
# }

# output "modify_policies" {
#   value       = { for table in var.tables : table.table_name => aws_iam_policy.modify[table.table_name].arn }
#   description = "ARNs of the modify policies for each table"
# }

# output "readonly_policies" {
#   value       = { for table in var.tables : table.table_name => aws_iam_policy.readonly[table.table_name].arn }
#   description = "ARNs of the readonly policies for each table"
# }
