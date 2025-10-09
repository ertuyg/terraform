variable "user_pool_name" {
  description = "Cognito User Pool Name"
}

variable "client_name" {
  description = "Cognito Client Name"
}

variable "username_attributes" {
  description = "Attributes for username"
  type        = list(string)
  default     = ["email"]
}


variable "auto_verified_attributes" {
  description = "Attributes for username"
  type        = list(string)
  default     = ["email"]
}

variable "minimum_length" {
  description = "Minimum password length"
  type        = number
  default     = 10
}

variable "require_lowercase" {
  description = "Require at least one lowercase letter in the password"
  type        = bool
  default     = true
}

variable "require_numbers" {
  description = "Require at least one number in the password"
  type        = bool
  default     = true
}

variable "require_symbols" {
  description = "Require at least one symbol in the password"
  type        = bool
  default     = true
}

variable "require_uppercase" {
  description = "Require at least one uppercase letter in the password"
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "Number of days for temporary password validity"
  type        = number
  default     = 7
}

variable "client_generate_secret" {
  description = "Generate secret for client"
  type        = bool
  default     = false
}

variable "access_token_validity_unit" {
  description = "Access token validity"
  type        = string
  default     = "hours"
}

variable "access_token_validity" {
  description = "Access token validity"
  type        = number
  default     = 10
}

variable "id_token_validity_unit" {
  description = "ID token validity"
  type        = string
  default     = "hours"
}

variable "id_token_validity" {
  description = "ID token validity"
  type        = number
  default     = 10
}

variable "refresh_token_validity_unit" {
  description = "Refresh token validity"
  type        = string
  default     = "days"
}

variable "refresh_token_validity" {
  description = "Refresh token validity"
  type        = number
  default     = 30
}
variable "prevent_user_existence_errors" {
  description = "Prevent user existence errors"
  type        = string
  default     = "ENABLED"

}

variable "explicit_auth_flows" {
  description = "Explicit auth flows"
  type        = list(string)
  default = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]

}

variable "schema" {
  description = "Cognito User Pool Schema Configuration"
  type = list(object({
    attribute_data_type      = string
    developer_only_attribute = bool
    mutable                  = bool
    name                     = string
    required                 = bool
    string_attribute_constraints = object({
      min_length = number
      max_length = number
    })
  }))
  default = [{
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true
    string_attribute_constraints = {
      min_length = 1
      max_length = 256
    }
    },
    {
      name                     = "name"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      required                 = true
      string_attribute_constraints = {
        min_length = 1
        max_length = 256
      }
  }]
}

variable "recovery_mechanism" {
  description = "Cognito User Pool Account Recovery Setting Recovery Mechanism"
  type = list(object({
    name     = string
    priority = number
  }))
  default = [
    {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]
}

variable "pre_token_generation_lambda_arn" {
  description = "Lambda ARN to use for Cognito Pre Token Generation trigger (optional)"
  type        = string
  default     = null
}

variable "pre_token_generation_lambda_version" {
  description = "Lambda trigger version for Pre Token Generation (e.g., V2_0). Ignored when ARN is null."
  type        = string
  default     = "V2_0"
}

variable "enable_pre_token_generation" {
  description = "Explicitly enable Pre Token Generation trigger resources (useful when ARN is computed)."
  type        = bool
  default     = false
}

