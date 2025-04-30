output "policy_arn" {
  description = "ARNs of the created SQS policies"
  value       = aws_iam_policy.this.arn
}

output "queue_arn" {
  description = "ARNs of the created SQS queues"
  value       = aws_sqs_queue.this.arn
}
output "queue_url" {
  description = "URLs of the created SQS queues"
  value       = aws_sqs_queue.this.url
}
