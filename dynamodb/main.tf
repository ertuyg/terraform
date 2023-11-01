resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key

  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  attribute {
    name = var.range_key
    type = var.range_key_type
  }

  dynamic "attribute" {
    for_each = var.additional_attributes
    content {
      name = each.value.name
      type = each.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = each.key
      hash_key        = each.value.hash_key
      range_key       = each.value.range_key
      projection_type = each.value.projection_type
      #   read_capacity   = var.billing_mode == "PROVISIONED" ? global_secondary_index.read_capacity : null
      #   write_capacity  = var.billing_mode == "PROVISIONED" ? global_secondary_index.write_capacity : null      
    }
  }


  # stream_enabled   = true
  # stream_view_type = "NEW_AND_OLD_IMAGES"

}


resource "aws_iam_policy" "readwrite" {
  name        = "DynamoDBModify-${var.table_name}"
  description = "Allows modification for DynamoDB table ${var.table_name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:BatchGetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem",
          "dynamodb:BatchWriteItem"
        ],
        Resource = [
          aws_dynamodb_table.this.arn,
          "${aws_dynamodb_table.this.arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "readonly" {
  name        = "DynamoDBReadonly-${var.table_name}"
  description = "Allows readonly for DynamoDB table ${var.table_name}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:BatchGetItem"
        ],
        Resource = [
          aws_dynamodb_table.this.arn,
          "${aws_dynamodb_table.this.arn}/index/*"
        ]
      }
    ]
  })
}



##### eğer GSI varsa o indexede yetki ver demek istersek 
# locals {
#   dynamodb_table_arns = concat(
#     [aws_dynamodb_table.this.arn], # ana tablo ARN'si
#     [for gsi in var.global_secondary_indexes : "${aws_dynamodb_table.this.arn}/index/${gsi.name}"] # GSI ARN'leri
#   )
# }

# resource "aws_iam_policy" "modify" {
#   name        = "DynamoDBModify-${var.table_name}"
#   description = "Allows modification for DynamoDB table ${var.table_name}"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = ["dynamodb:PutItem", "dynamodb:DeleteItem", "dynamodb:UpdateItem", "dynamodb:BatchWriteItem"],
#         Resource = local.dynamodb_table_arns
#       }
#     ]
#   })
# }
