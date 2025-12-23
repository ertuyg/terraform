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
  default     = "nodejs20.x"
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

variable "lambda_memory_size" {
  description = "The amount of memory in MB your Lambda Function can use at runtime."
  type        = number
  default     = 256
}

variable "ephemeral_storage_size" {
  description = "The size of the Lambda function Ephemeral storage (/tmp) in MB. Valid values: 512 to 10240."
  type        = number
  default     = 512
}

variable "dead_letter_config" {
  description = "The dead letter configuration for the Lambda function."
  type = object({
    target_arn = string
  })
  default = null

}
