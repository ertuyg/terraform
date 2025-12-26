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
  description = "The amount of memory in MB your Lambda Function can use at runtime. Set to null to use AWS default (128 MB)."
  type        = number
  default     = 256
  nullable    = true

  validation {
    condition     = var.lambda_memory_size == null || (var.lambda_memory_size >= 128 && var.lambda_memory_size <= 10240)
    error_message = "Lambda memory_size must be null (uses AWS default 128 MB) or between 128 and 10240 MB."
  }
}

variable "ephemeral_storage_size" {
  description = "The size of the Lambda function Ephemeral storage (/tmp) in MB. Valid values: 512 to 10240. Set to null to use AWS default (512 MB)."
  type        = number
  default     = 512
  nullable    = true

  validation {
    condition     = var.ephemeral_storage_size == null || (var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240)
    error_message = "Lambda ephemeral_storage_size must be null (uses AWS default 512 MB) or between 512 and 10240 MB."
  }
}

variable "dead_letter_config" {
  description = "The dead letter configuration for the Lambda function."
  type = object({
    target_arn = string
  })
  default = null

}
