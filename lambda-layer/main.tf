# resource "aws_lambda_layer_version" "this" {
#   layer_name          = var.name
#   filename            = data.archive_file.this.output_path
#   source_code_hash    = data.archive_file.this.output_base64sha256
#   description         = var.description
#   compatible_runtimes = var.compatible_runtimes
#   # lifecycle {
#   #   ignore_changes = [
#   #     filename,
#   #     source_code_hash,
#   #   ]
#   # }
# }

# data "archive_file" "this" {
#   type        = "zip"
#   source_dir  = var.source_path
#   output_path = "s3_archives/layers/${var.name}.zip"
# }

# Archive sadece istenirse oluşturulsun
data "archive_file" "this" {
  count       = var.use_existing_zip ? 0 : 1
  type        = "zip"
  source_dir  = var.source_path
  output_path = "s3_archives/layers/${var.name}.zip"
}

resource "aws_lambda_layer_version" "this" {
  layer_name          = var.name
  filename            = var.use_existing_zip ? "s3_archives/layers/${var.name}.zip" : data.archive_file.this[0].output_path
  source_code_hash    = var.use_existing_zip ? filesha256("s3_archives/layers/${var.name}.zip") : data.archive_file.this[0].output_base64sha256
  description         = var.description
  compatible_runtimes = var.compatible_runtimes
}
