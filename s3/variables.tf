variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string

}

variable "enable_website" {
  description = "Enable the S3 bucket as a website"
  type        = bool
  default     = false
}

variable "enable_cors" {
  description = "Enable the S3 bucket CORS"
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "The list of allowed origins for CORS"
  type        = list(string)
  default     = []
}

variable "website_configuration_index_document" {
  description = "The name of the index document."
  type        = string
  default     = "index.html"
}

variable "website_configuration_error_document" {
  description = "The name of the error document."
  type        = string
  default     = "index.html"
}

variable "access_lambda" {
  description = "Enable the S3 bucket access from lambda"
  type        = bool
  default     = false
}


variable "is_public" {
  description = "Enable the S3 bucket as a website"
  type        = bool
  default     = false
}
