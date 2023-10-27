variable "api_name" {
  description = "The name of the API."
  type        = string
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

variable "stage" {
  description = "The name of the API Stage."
  type        = string
}

variable "db_modify_policies" {
  description = "ARNs of the modify policies for each table"
  type        = map(string)
  default     = {}
}

variable "db_readonly_policies" {
  description = "ARNs of the readonly policies for each table"
  type        = map(string)
  default     = {}
}


variable "lambda_configurations" {
  description = "Configuration for Lambda functions and their API Gateway integrations"
  type = list(object({
    function_name = string
    runtime       = string
    handler       = string
    source_path   = string
    environment   = optional(map(string))

    integrate_with_api = bool
    http_method        = string
    route              = string
    use_authorization  = bool

    layers = optional(list(string))

    dynamodb_access = list(object({
      table_name  = string
      access_type = string # "readonly" veya "modify"
    }))
  }))
}
