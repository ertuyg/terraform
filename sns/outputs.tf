output "sns_topic_arn" {
  description = "ARN of the created SNS topic"
  value       = aws_sns_topic.this.arn
}

output "sns_topic_name" {
  description = "Name of the created SNS topic"
  value       = aws_sns_topic.this.name
}

# output "sns_subscriptions" {
#   description = "List of SNS subscription ARNs"
#   value = [
#     for s in aws_sns_topic_subscription.this : s.arn
#   ]
# }

output "sns_policy_arn" {
  description = "IAM policy ARN to allow Lambda to publish to the SNS topic"
  value       = aws_iam_policy.this.arn
}
