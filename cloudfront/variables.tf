variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  type        = map(string)
  default = {
    "Name" = "${var.bucket_name} cloudfront distribution"
  }
}

variable "s3_origin_id" {
  description = "The unique identifier for the S3 origin."
  type        = string
}

variable "aliases" {
  description = "A list of domain names for the distribution."
  type        = list(string)
  default     = [] #["mysite.example.com", "yoursite.example.com"]
}

variable "Environment" {
  description = "The environment for the resources."
  type        = string
  default     = "dev"

}
