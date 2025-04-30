variable "queue_name" {
  description = "The name of the SQS queue"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function to trigger"
  type        = string
}
variable "lambda_function_arn" {
  description = "The ARN of the Lambda function to trigger"
  type        = string
}

variable "visibility_timeout" {
  description = "The visibility timeout for the SQS queue in seconds"
  type        = number
  default     = null
}

variable "redrive_policy" {
  description = "The redrive policy for the SQS queue"
  type = object({
    dead_letter_target_arn = string
    max_receive_count      = number
  })
  default = null
}

variable "lambda_maximum_retry_attempts" {
  description = "The maximum number of times to retry the Lambda function in case of failure"
  type        = number
  default     = null

}
