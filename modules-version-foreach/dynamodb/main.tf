resource "aws_dynamodb_table" "dynamodb_table" {
  for_each = { for table in var.tables : table.table_name => table }

  name         = each.value.table_name
  billing_mode = each.value.billing_mode
  hash_key     = each.value.hash_key
  range_key    = each.value.range_key

  read_capacity  = each.value.billing_mode == "PROVISIONED" ? each.value.read_capacity : null
  write_capacity = each.value.billing_mode == "PROVISIONED" ? each.value.write_capacity : null

  attribute {
    name = each.value.hash_key
    type = each.value.hash_key_type
  }

  attribute {
    name = each.value.range_key
    type = each.value.range_key_type
  }

  dynamic "attribute" {
    for_each = each.value.additional_attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = each.value.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type
      #   read_capacity   = each.value..billing_mode == "PROVISIONED" ? global_secondary_index.read_capacity : null
      #   write_capacity  = each.value..billing_mode == "PROVISIONED" ? global_secondary_index.write_capacity : null      
    }
  }


  # stream_enabled   = true
  # stream_view_type = "NEW_AND_OLD_IMAGES"

}

