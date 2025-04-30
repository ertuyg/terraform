resource "aws_sns_topic" "this" {
  name = var.topic_name
}

resource "aws_sns_topic_subscription" "this" {
  for_each = { for idx, sub in var.subscriptions : idx => sub }

  topic_arn = aws_sns_topic.this.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint

  raw_message_delivery = contains(keys(each.value), "raw_message_delivery") ? each.value.raw_message_delivery : null
  filter_policy        = contains(keys(each.value), "filter_policy") ? jsonencode(each.value.filter_policy) : null
}

resource "aws_iam_policy" "this" {
  name        = "LambdaSNSTopicPolicy-${var.topic_name}"
  description = "Policy for Lambda to access SNS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sns:Publish"]
        Resource = [
          aws_sns_topic.this.arn
        ]
      }
    ]
  })
}

resource "aws_lambda_permission" "this" {
  for_each = {
    for idx, sub in var.subscriptions :
    idx => sub if sub.protocol == "lambda" && contains(keys(sub), "lambda_function_name")
  }

  statement_id  = "AllowExecutionFromSNS-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.this.arn
}
