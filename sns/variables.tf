
variable "topic_name" {
  description = "The name of the SNS topic"
  type        = string
}


variable "subscriptions" {
  description = <<EOT
List of subscriptions. Each item should have:
- protocol (e.g. email, sms, lambda, sqs, https)
- endpoint (email address, phone number, Lambda ARN, etc.)
Optional:
- raw_message_delivery (bool)
- filter_policy (map)
EOT
  type = list(object({
    protocol             = string
    endpoint             = string
    lambda_function_name = optional(string)
    raw_message_delivery = optional(bool)
    filter_policy        = optional(map(string))
  }))
}
