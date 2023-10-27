resource "aws_iam_role" "lambda_execution_roles" {
  for_each = { for lambda in var.lambda_configurations : lambda.function_name => lambda }

  name = "lambda_execution_role-${each.key}"

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

locals {
  lambda_attachments = flatten([
    for lambda in var.lambda_configurations : [
      for access in lookup(lambda, "dynamodb_access", []) : {
        lambda_name = lambda.function_name,
        policy_arn  = access.access_type == "readonly" ? var.db_readonly_policies[access.table_name] : var.db_modify_policies[access.table_name],
        access_type = access.access_type
      }
    ]
  ])
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  for_each = { for att in local.lambda_attachments : "${att.lambda_name}-${att.access_type}" => att }

  role       = aws_iam_role.lambda_execution_roles[each.value.lambda_name].name
  policy_arn = each.value.policy_arn
}
