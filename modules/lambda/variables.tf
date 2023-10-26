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

variable "db_policies" {
  description = "Map of DynamoDB policies for the Lambda functions."
  type        = map(string)
  default     = {}
}

# variable "db_configs" {
#   description = "Configuration for database permissions"
#   type = list(object({
#     table_name = string
#     permission = string
#   }))
#   default = []
# }
