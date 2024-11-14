data "archive_file" "this" {
  type        = "zip"
  source_dir  = can(file(var.source_path)) ? null : var.source_path
  source_file = can(file(var.source_path)) ? var.source_path : null
  output_path = "s3_archives/lambda/${var.function_name}.zip"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  handler       = var.handler
  role          = aws_iam_role.lambda_execution_role.arn
  runtime       = var.runtime

  source_code_hash = data.archive_file.this.output_base64sha256
  filename         = data.archive_file.this.output_path
  timeout          = var.lambda_timeout

  environment {
    variables = var.environment_variables
  }

  layers = var.layers
  # lifecycle {
  #   ignore_changes = [
  #     filename,
  #     # source_code_hash,
  #   ]
  # }

}

resource "aws_iam_role" "lambda_execution_role" {

  name = "lambda_execution_role-${var.function_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  for_each   = var.policy_attachments
  policy_arn = each.value
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}" #aws_lambda_function.this.function_name
  retention_in_days = var.log_retention
}
