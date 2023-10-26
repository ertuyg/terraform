variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region for all resources."
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "api_name" {
  type    = string
  default = "pruva-api"
}

variable "version_number" {
  type    = string
  default = "v1"
}


variable "dist_root_dir" {
  type    = string
  default = "../../dist"
}


variable "s3_output_root_dir" {
  type    = string
  default = "../../toS3"
}
