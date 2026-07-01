variable "user_pool_name" {
  description = "Cognito User Pool Name"
}

variable "client_name" {
  description = "Cognito Client Name (optional - if not provided, only clients will be created)"
  type        = string
  default     = null
}

variable "username_attributes" {
  description = "Attributes for username"
  type        = list(string)
  default     = ["email"]
}


variable "auto_verified_attributes" {
  description = "Attributes to be auto-verified"
  type        = list(string)
  default     = ["email"]
}

variable "enable_email_verification" {
  description = "Enable email verification (ensures email is in auto_verified_attributes)"
  type        = bool
  default     = false
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

variable "post_confirmation_lambda_arn" {
  description = "Lambda ARN to use for Cognito Post Confirmation trigger (optional)"
  type        = string
  default     = null
}

variable "enable_post_confirmation" {
  description = "Explicitly enable Post Confirmation trigger resources (useful when ARN is computed)."
  type        = bool
  default     = false
}

variable "post_authentication_lambda_arn" {
  description = "Lambda ARN to use for Cognito Post Authentication trigger (optional)"
  type        = string
  default     = null
}

variable "enable_post_authentication" {
  description = "Explicitly enable Post Authentication trigger resources (useful when ARN is computed)."
  type        = bool
  default     = false
}

variable "custom_message_lambda_arn" {
  description = "Lambda ARN to use for Cognito Custom Message trigger (optional)"
  type        = string
  default     = null
}

variable "enable_custom_message" {
  description = "Explicitly enable Custom Message trigger resources (useful when ARN is computed)."
  type        = bool
  default     = false
}

variable "enable_google_idp" {
  type    = bool
  default = false
}

variable "google_client_id" {
  type      = string
  default   = null
  sensitive = true
}

variable "google_client_secret" {
  type      = string
  default   = null
  sensitive = true
}

variable "callback_urls" {
  type    = list(string)
  default = []
  # örn: ["https://math.energy/auth/callback"]
}

variable "logout_urls" {
  type    = list(string)
  default = []
  # örn: ["https://math.energy/"]
}

variable "cognito_domain_prefix" {
  type    = string
  default = null
  # örn: "math-energy-auth"
}

variable "verification_message_template" {
  description = "Verification message template configuration (optional)"
  type = object({
    default_email_option  = optional(string, "CONFIRM_WITH_CODE") # CONFIRM_WITH_CODE or CONFIRM_WITH_LINK
    email_subject         = optional(string)
    email_message         = optional(string)
    email_message_by_link = optional(string)
    sms_message           = optional(string)
  })
  default = null
}

variable "clients" {
  description = "Cognito User Pool Clients (optional, for multiple clients support)"
  type = list(object({
    name                                 = string
    generate_secret                      = optional(bool, false)
    explicit_auth_flows                  = optional(list(string), ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_ADMIN_USER_PASSWORD_AUTH"])
    access_token_validity                = optional(number, 10)
    id_token_validity                    = optional(number, 10)
    refresh_token_validity               = optional(number, 30)
    access_token_validity_unit           = optional(string, "hours")
    id_token_validity_unit               = optional(string, "hours")
    refresh_token_validity_unit          = optional(string, "days")
    prevent_user_existence_errors        = optional(string, "ENABLED")
    allowed_oauth_flows                  = optional(list(string))
    allowed_oauth_scopes                 = optional(list(string))
    allowed_oauth_flows_user_pool_client = optional(bool, false)
    supported_identity_providers         = optional(list(string), ["COGNITO"])
    callback_urls                        = optional(list(string), [])
    logout_urls                          = optional(list(string), [])
    # AWS CLI describe-user-pool-client çıktısında bu alan hiç görünmüyordu (implicit
    # default'a güvenmek yerine explicit true set ediyoruz) — RevokeToken API'sinin
    # gerçekten işe yaraması için gerekli.
    enable_token_revocation = optional(bool, true)
  }))
  default = []
}


variable "admin_create_user_config" {
  description = "Configuration for admin-created users (invite flow). invite_message_template uses {username} and {####} placeholders."
  type = object({
    allow_admin_create_user_only = optional(bool, false)
    invite_message_template = optional(object({
      email_subject = string
      email_message = string
      sms_message   = optional(string)
    }))
  })
  default = null
}

variable "email_configuration" {
  description = "Cognito email configuration. Use DEVELOPER to send emails through Amazon SES."
  type = object({
    email_sending_account  = optional(string, "COGNITO_DEFAULT")
    source_arn             = optional(string)
    from_email_address     = optional(string)
    reply_to_email_address = optional(string)
  })
  default = null
}
