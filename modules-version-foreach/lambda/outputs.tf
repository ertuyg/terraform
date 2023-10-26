output "lambda_arns" {
  description = "ARNs of the Lambda functions"
  value       = { for conf in var.lambda_configurations : conf.function_name => aws_lambda_function.this[conf.function_name].arn }
}
