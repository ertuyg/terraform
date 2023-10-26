
#### Bu modül hiç api gw olmayan projeler için geçerli. 
#### Eğer api gw varsa diğer modülü kullan. 
#### Onun içerisinde apigw olmadan zaten gidebiliiyorsun.  

resource "aws_iam_role" "lambda_execution_role" {
  name = "onlylambda_execution_role"

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


data "archive_file" "lambda_zip" {
  for_each = { for conf in var.lambda_configurations : conf.function_name => conf }

  type        = "zip"
  source_dir  = can(file(each.value.source_path)) ? null : each.value.source_path
  source_file = can(file(each.value.source_path)) ? each.value.source_path : null
  output_path = "s3_archives/lambda/${each.key}.zip"
}

resource "aws_lambda_function" "this" {
  for_each = { for conf in var.lambda_configurations : conf.function_name => conf }

  function_name = each.value.function_name
  handler       = each.value.handler
  runtime       = each.value.runtime
  role          = aws_iam_role.lambda_execution_role.arn

  filename         = data.archive_file.lambda_zip[each.key].output_path
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256

  environment {
    variables = each.value.environment
  }

  layers = lookup(each.value, "layers", [])

}
