variable "bucket_name" {
  description = "The name of the S3 bucket. (Legacy - use 'origins' for multi-origin setup)"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  type        = map(string)
  default = {
    "Name" = "cloudfront distribution"
  }
}

variable "s3_origin_id" {
  description = "The unique identifier for the S3 origin. (Legacy - use 'origins' for multi-origin setup)"
  type        = string
  default     = null
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

variable "origin_access_control_name" {
  description = "The name of the origin access control. (Legacy - use 'origins' for multi-origin setup)"
  type        = string
  default     = null
}

variable "origins" {
  description = "List of S3 origin objects for this distribution. If empty, uses legacy single-origin variables."
  type = list(object({
    bucket_name                = string
    origin_id                  = string
    origin_path                = optional(string, "")
    origin_access_control_name = optional(string, null)
    origin_access_control_id   = optional(string, null)
  }))
  default = []
}

variable "ordered_cache_behaviors" {
  description = "List of ordered cache behaviors for this distribution."
  type = list(object({
    path_pattern           = string
    target_origin_id       = string
    allowed_methods        = optional(list(string), ["GET", "HEAD", "OPTIONS"])
    cached_methods         = optional(list(string), ["GET", "HEAD"])
    compress               = optional(bool, true)
    viewer_protocol_policy = optional(string, "redirect-to-https")
    min_ttl                = optional(number, 0)
    default_ttl            = optional(number, 3600)
    max_ttl                = optional(number, 86400)
    query_string           = optional(bool, false)
    cookies_forward        = optional(string, "none")
  }))
  default = []
}
