output "invoke_arn" {
  description = "The ARN to be used for invoking Lambda function from other AWS services (like API Gateway)"
  value       = aws_lambda_function.this.invoke_arn
}

output "lambda_arn" {
  description = "The ARN to be used for invoking Lambda function from other AWS services (like API Gateway)"
  value       = aws_lambda_function.this.arn
}
