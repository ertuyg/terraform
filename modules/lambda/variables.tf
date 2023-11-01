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

variable "log_retention" {
  description = "The Lambda Log retention in days."
  type        = number
  default     = 7
}

variable "lambda_timeout" {
  description = "The Lambda timeout in seconds."
  type        = number
  default     = 5
}
