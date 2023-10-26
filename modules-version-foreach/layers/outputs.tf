output "layer_arns" {
  description = "The ARNs of the Lambda layers."
  value       = { for k, v in aws_lambda_layer_version.this : k => v.arn }
}
