resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = var.protocol_type
  cors_configuration {
    allow_origins = var.cors_allow_origins
    allow_methods = var.cors_allow_methods
    allow_headers = var.cors_allow_headers
    max_age       = var.cors_max_age
  }
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage
  auto_deploy = true
  #  TODO: log ları kullanıp kullanmamaya sonra bakalım bunlar zaten lambda üzerinden loglanıyor. apigw de gerek olmayabilir. 
  #   access_log_settings {
  #     destination_arn = aws_cloudwatch_log_group.api_gw.arn

  #     format = jsonencode({
  #       requestId               = "$context.requestId"
  #       sourceIp                = "$context.identity.sourceIp"
  #       requestTime             = "$context.requestTime"
  #       protocol                = "$context.protocol"
  #       httpMethod              = "$context.httpMethod"
  #       resourcePath            = "$context.resourcePath"
  #       routeKey                = "$context.routeKey"
  #       status                  = "$context.status"
  #       responseLength          = "$context.responseLength"
  #       integrationErrorMessage = "$context.integrationErrorMessage"
  #       }
  #     )
  #   }  
}

# auto deploy olduğu için gerek yok. 
# resource "aws_apigatewayv2_deployment" "this" {
#   api_id = aws_apigatewayv2_api.this.id

#   lifecycle {
#     create_before_destroy = true
#   }
# }


resource "aws_apigatewayv2_integration" "this" {
  for_each = var.routes

  api_id = aws_apigatewayv2_api.this.id

  integration_uri        = each.value.invoke_arn # var.lambda_invoke_arns[each.value.lambda_function_name]
  integration_type       = lookup(each.value, "integration_type", "AWS_PROXY")
  integration_method     = lookup(each.value, "integration_method", "POST")
  payload_format_version = lookup(each.value, "payload_format_version", "2.0")
  # ... diğer özellikler ...
}

resource "aws_apigatewayv2_route" "this" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.this.id
  route_key = "${each.value.http_method} /${each.value.route_key}"
  target    = "integrations/${aws_apigatewayv2_integration.this[each.key].id}"

  # Eğer use_authorization = true ise, bu özelliği kullanabilirsiniz
  authorization_type = each.value.use_authorization ? "JWT" : null
  authorizer_id      = each.value.use_authorization ? aws_apigatewayv2_authorizer.cognito_authorizer.id : null

}
# bu belki lambda modülüne taşınabilir ama integration yoksa bu yok bu nedenle burada durması daha mantıklı
resource "aws_lambda_permission" "this" {
  for_each      = var.routes
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/${each.value.http_method}/${each.value.route_key}" #"arn:aws:execute-api:region:account-id:api-id/stage/METHOD_HTTP_VERB/Resource-path"
}



resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id           = aws_apigatewayv2_api.this.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.api_name}Authorizer"
  jwt_configuration {
    issuer   = var.cognito_user_pool_issuer
    audience = [var.cognito_user_pool_client_id]
  }
}

#  TODO: eğer logları kullanmak istersek bunları da ekleyebiliriz.
# resource "aws_cloudwatch_log_group" "this" {
#   name = "/aws/apigateway/${aws_apigatewayv2_api.this.name}"
# }
