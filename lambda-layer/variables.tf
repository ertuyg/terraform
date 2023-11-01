variable "name" {
  description = "The name of the Layer"
  type        = string
}

variable "source_path" {
  description = "The path to the source code of the Layer"
  type        = string
}

variable "description" {
  description = "The description of the Layer"
  type        = string
  default     = ""
}

variable "compatible_runtimes" {
  description = "The runtimes that the Layer is compatible with"
  type        = list(string)
  default     = []
}
