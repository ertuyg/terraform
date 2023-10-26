resource "aws_iam_policy" "modify" {
  for_each = { for table in var.tables : table.table_name => table }

  name        = "DynamoDBModify-${each.value.table_name}"
  description = "Allows modification for DynamoDB table ${each.value.table_name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:UpdateItem", "dynamodb:BatchWriteItem"],
        Resource = aws_dynamodb_table.dynamodb_table[each.key].arn
      }
    ]
  })
}

resource "aws_iam_policy" "readonly" {
  for_each = { for table in var.tables : table.table_name => table }

  name        = "DynamoDBReadonly-${each.value.table_name}"
  description = "Allows readonly for DynamoDB table ${each.value.table_name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["dynamodb:GetItem", "dynamodb:Scan", "dynamodb:Query", "dynamodb:BatchGetItem"],
        Resource = aws_dynamodb_table.dynamodb_table[each.key].arn
      }
    ]
  })
}

# resource "aws_iam_role" "dynamodb_role" {
#   name = "DynamoDBRole-${each.value.table_name}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         },
#         Effect = "Allow",
#         Sid    = ""
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "modify_attachment" {
#   for_each = { for table in var.tables : table.table_name => table }

#   policy_arn = aws_iam_policy.modify[each.key].arn
#   role       = aws_iam_role.dynamodb_role.name
# }

# resource "aws_iam_role_policy_attachment" "readonly_attachment" {
#   for_each = { for table in var.tables : table.table_name => table }

#   policy_arn = aws_iam_policy.readonly[each.key].arn
#   role       = aws_iam_role.dynamodb_role.name
# }
