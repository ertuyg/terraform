variable "api_name" {
  description = "The name of the API."
  type        = string
}

variable "stage" {
  description = "The name of the API Stage."
  type        = string
}

variable "protocol_type" {
  description = "Valid values: HTTP, WEBSOCKET."
  type        = string
  default     = "HTTP"
}

variable "cors_allow_origins" {
  description = "The list of allowed origins for CORS."
  type        = list(string)
  default     = ["*"]
}

variable "cors_allow_methods" {
  description = "The list of allowed methods for CORS."
  type        = list(string)
  default     = ["POST", "GET", "OPTIONS", "DELETE", "PUT"]
}

variable "cors_allow_headers" {
  description = "The list of allowed headers for CORS."
  type        = list(string)
  default     = ["*"]
}

variable "cors_max_age" {
  description = "The time in seconds that the browser should cache the preflight request results."
  default     = 300
}

# variable "lambda_invoke_arns" {
#   description = "The map of Lambda ARNs to be integrated with the API."
#   type        = map(string)
# }

variable "routes" {
  description = "The list of routes for the API."
  type = map(object({
    invoke_arn           = string
    http_method          = string
    lambda_function_name = string
    use_authorization    = bool
    route_key            = string
  }))
}

variable "cognito_user_pool_issuer" {
  description = "Cognito User Pool Issuer"
  type        = string
  default     = ""
}

variable "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID (DEPRECATED - use cognito_user_pool_client_ids instead; kept for backward compatibility)"
  type        = string
  default     = ""
}

variable "cognito_user_pool_client_ids" {
  description = "Cognito User Pool Client IDs (list) - supports multiple client IDs for JWT authorizer audience"
  type        = list(string)
  default     = []
}

variable "enable_cognito_jwt_authorizer" {
  description = <<-EOT
    Required. When true, creates the API Gateway JWT authorizer (count is driven only by this flag, not by audience/client ids).

    When false, no authorizer exists. If any route sets use_authorization = true, this must be true (enforced by validation).
  EOT
  type        = bool

  validation {
    condition     = !contains([for r in var.routes : r.use_authorization], true) || var.enable_cognito_jwt_authorizer
    error_message = "When any route has use_authorization = true, enable_cognito_jwt_authorizer must be true (otherwise JWT is not attached and the route would be effectively open)."
  }
}
