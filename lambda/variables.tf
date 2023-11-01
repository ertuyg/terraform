variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "The handler for the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The runtime environment for the Lambda function"
  type        = string
}

variable "api_gateway_arn" {
  description = "The ARN of the API Gateway resource."
  type        = string
  default     = ""
}


variable "environment_variables" {
  description = "The ARN of the API Gateway resource."
  type        = map(string)
  default     = {}
}

variable "layers" {
  description = "The ARN of the API Gateway resource."
  type        = list(string)
  default     = []
}

variable "source_path" {
  description = "The ARN of the API Gateway resource."
  type        = string
}

variable "policy_attachments" {
  description = "Map of Role policy attachments for the Lambda functions."
  type        = map(string)
  default     = {}
}

# variable "add_cognito_policy" {
#   description = "Add the Cognito policy to the Lambda function."
#   type        = bool
#   default     = false
# }
# variable "cognito_pool_arn" {
#   description = "The Cognito pool Arn."
#   type        = string
# }
# variable "db_configs" {
#   description = "Configuration for database permissions"
#   type = list(object({
#     table_name = string
#     permission = string
#   }))
#   default = []
# }
