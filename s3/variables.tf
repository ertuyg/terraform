variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string

}

variable "enable_website" {
  description = "Enable the S3 bucket as a website"
  type        = bool
  default     = false
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
