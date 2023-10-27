output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = aws_apigatewayv2_api.this.api_endpoint
}

# output "routes" {
#   value = aws_apigatewayv2_route.this["projects_get"].route_key
# }

# output "function_name" {
#   value = aws_lambda_permission.api_gateway_permission["projects_get"]
# }
