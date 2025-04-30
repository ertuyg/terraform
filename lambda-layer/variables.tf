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
  default     = ["nodejs16.x", "nodejs18.x", "nodejs20.x", "nodejs22.x"]
}

variable "use_existing_zip" {
  description = "Whether to use an existing zip file instead of creating a new one"
  type        = bool
  default     = false
}

variable "zip_path" {
  description = "Eğer hazır zip kullanılacaksa, dosya path'i"
  type        = string
  default     = ""
}
