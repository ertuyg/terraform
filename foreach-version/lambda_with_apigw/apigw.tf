

resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = "HTTP"
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
  #   deployment_id = aws_apigatewayv2_deployment.this.id # auto deploy olduğu için buna gerek yok.  

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


# resource "aws_apigatewayv2_authorizer" "jwt_authorizer" {
#   api_id           = aws_apigatewayv2_api.this.id
#   authorizer_type  = "JWT"
#   identity_sources = ["$request.header.Authorization"]
#   name             = "${var.api_name}Authorizer"

#   jwt_configuration {
#     audience = ["AUDIENCE_VALUE"]    #TODO: cognitoya bağla
#     issuer   = "https://pruvapm.com" #TODO: cognitoya bağla
#   }
# }

resource "aws_apigatewayv2_route" "this" {
  for_each = { for conf in var.lambda_configurations : conf.function_name => conf if conf.integrate_with_api }

  api_id    = aws_apigatewayv2_api.this.id
  route_key = "${each.value.http_method} ${each.value.route}"
  target    = "integrations/${aws_apigatewayv2_integration.this[each.value.function_name].id}"
  # authorizer_id = each.value.use_authorization ? aws_apigatewayv2_authorizer.jwt_authorizer.id : null

}

resource "aws_apigatewayv2_integration" "this" {
  for_each = { for conf in var.lambda_configurations : conf.function_name => conf if conf.integrate_with_api }

  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_method     = each.value.http_method # "POST"
  integration_uri        = aws_lambda_function.this[each.value.function_name].arn
  payload_format_version = "2.0"
}


resource "aws_lambda_permission" "api_gateway_permission" {
  for_each = { for conf in var.lambda_configurations : conf.function_name => conf if conf.integrate_with_api }

  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this[each.value.function_name].function_name
  principal     = "apigateway.amazonaws.com"

  # Source ARN for API Gateway resource
  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/${each.value.http_method}${each.value.route}"
}


#  TODO: eğer logları kullanmak istersek bunları da ekleyebiliriz.
# resource "aws_cloudwatch_log_group" "this" {
#   name = "/aws/apigateway/${aws_apigatewayv2_api.this.name}"
# }
