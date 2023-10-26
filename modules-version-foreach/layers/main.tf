resource "aws_lambda_layer_version" "this" {
  for_each = { for layer in var.layers : layer.name => layer }

  layer_name          = each.value.name
  filename            = data.archive_file.layer_zip[each.key].output_path
  source_code_hash    = data.archive_file.layer_zip[each.key].output_base64sha256
  description         = each.value.description
  compatible_runtimes = each.value.compatible_runtimes
}

data "archive_file" "layer_zip" {
  for_each = { for layer in var.layers : layer.name => layer }

  type        = "zip"
  source_dir  = each.value.source_path
  output_path = "s3_archives/layers/${each.key}.zip"
}
