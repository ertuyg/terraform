
variable "layers" {
  description = "List of layers to create"
  type = list(object({
    name                = string
    source_path         = string
    description         = optional(string)
    compatible_runtimes = optional(list(string))
  }))
  default = []
}
