output "lambda_arns" {
  description = "ARNs of the Lambda functions"
  value       = { for conf in var.lambda_configurations : conf.function_name => aws_lambda_function.this[conf.function_name].arn }
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = aws_apigatewayv2_api.this.api_endpoint
}
