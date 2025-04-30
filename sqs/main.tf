resource "aws_sqs_queue" "this" {
  name                       = var.queue_name
  visibility_timeout_seconds = var.visibility_timeout != null ? var.visibility_timeout : null
  redrive_policy = var.redrive_policy != null ? jsonencode({
    deadLetterTargetArn = var.redrive_policy.dead_letter_target_arn
    maxReceiveCount     = var.redrive_policy.max_receive_count
  }) : null
}

resource "aws_iam_policy" "this" {
  name        = "LambdaSQSPolicy-${var.queue_name}"
  description = "Policy for Lambda to access SQS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        Resource = [
          aws_sqs_queue.this.arn
        ]
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "this" {
  event_source_arn       = aws_sqs_queue.this.arn
  function_name          = var.lambda_function_arn
  maximum_retry_attempts = var.lambda_maximum_retry_attempts != null ? var.lambda_maximum_retry_attempts : null
}
