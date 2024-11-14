output "invoke_arn" {
  description = "The ARN to be used for invoking Lambda function from other AWS services (like API Gateway)"
  value       = aws_lambda_function.this.invoke_arn
}

output "lambda_arn" {
  description = "The ARN to be used for invoking Lambda function from other AWS services (like API Gateway)"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}
