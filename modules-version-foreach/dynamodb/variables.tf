variable "tables" {
  description = "List of configurations for DynamoDB tables"
  type = list(object({
    table_name     = string
    hash_key       = string
    hash_key_type  = string
    range_key      = string
    range_key_type = string
    billing_mode   = string
    read_capacity  = optional(number)
    write_capacity = optional(number)
    additional_attributes = optional(list(object({
      name = string
      type = string
    })))
    global_secondary_indexes = optional(list(object({
      name            = string
      hash_key        = string
      range_key       = string
      projection_type = string
      # read_capacity   = optional(number)
      # write_capacity  = optional(number)      
    })))
  }))
  default = []
}


