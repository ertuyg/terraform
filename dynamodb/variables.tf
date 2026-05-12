variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}
variable "hash_key" {
  description = "Name of the hash key"
  type        = string
  default     = "PK"
}
variable "hash_key_type" {
  description = "Type of the hash key"
  type        = string
  default     = "S"
}
variable "range_key" {
  description = "Name of the range key"
  type        = string
  default     = "SK"
}
variable "range_key_type" {
  description = "Type of the range key"
  type        = string
  default     = "S"
}
variable "billing_mode" {
  description = "Billing mode of the DynamoDB table"
  type        = string
  default     = "PAY_PER_REQUEST"
}
variable "read_capacity" {
  description = "Read capacity of the DynamoDB table"
  type        = number
  default     = 0
}
variable "write_capacity" {
  description = "Write capacity of the DynamoDB table"
  type        = number
  default     = 0
}
variable "additional_attributes" {
  description = "Additional attributes of the DynamoDB table"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "global_secondary_indexes" {
  description = <<-EOT
    Global secondary indexes. projection_type: KEYS_ONLY, INCLUDE, or ALL.
    For INCLUDE, set non_key_attributes to a non-empty list of attribute names to project (those attributes must be declared in additional_attributes or as table keys).
  EOT
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string), null)
    # read_capacity   = optional(number)
    # write_capacity  = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for gsi in var.global_secondary_indexes :
      gsi.projection_type == "INCLUDE" ? length(coalesce(gsi.non_key_attributes, [])) > 0 : length(coalesce(gsi.non_key_attributes, [])) == 0
    ])
    error_message = "For projection_type INCLUDE, non_key_attributes must be a non-empty list. For KEYS_ONLY or ALL, omit non_key_attributes or use null (empty list is not valid for INCLUDE)."
  }
}

variable "ttl_enabled" {
  description = "Whether TTL is enabled for the DynamoDB table"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Name of the TTL attribute"
  type        = string
  default     = "ttl"
}
