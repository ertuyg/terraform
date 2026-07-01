
resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  username_attributes      = var.username_attributes
  auto_verified_attributes = var.enable_email_verification ? distinct(concat(var.auto_verified_attributes, ["email"])) : var.auto_verified_attributes
  password_policy {
    minimum_length                   = var.minimum_length
    require_lowercase                = var.require_lowercase
    require_numbers                  = var.require_numbers
    require_symbols                  = var.require_symbols
    require_uppercase                = var.require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
  }

  lifecycle {
    prevent_destroy = true
  }

  account_recovery_setting {
    dynamic "recovery_mechanism" {
      for_each = var.recovery_mechanism
      content {
        name     = recovery_mechanism.value.name
        priority = recovery_mechanism.value.priority
      }
    }
  }

  dynamic "schema" {
    for_each = var.schema
    content {
      name                     = schema.value.name
      attribute_data_type      = schema.value.attribute_data_type
      developer_only_attribute = schema.value.developer_only_attribute
      mutable                  = schema.value.mutable
      required                 = schema.value.required

      string_attribute_constraints {
        min_length = schema.value.string_attribute_constraints.min_length
        max_length = schema.value.string_attribute_constraints.max_length
      }
    }
  }

  dynamic "lambda_config" {
    for_each = (var.enable_pre_token_generation || var.enable_post_confirmation || var.enable_post_authentication || var.enable_custom_message) ? [1] : []
    content {
      dynamic "pre_token_generation_config" {
        for_each = var.enable_pre_token_generation ? [1] : []
        content {
          lambda_arn     = var.pre_token_generation_lambda_arn
          lambda_version = var.pre_token_generation_lambda_version
        }
      }

      post_confirmation   = var.enable_post_confirmation ? var.post_confirmation_lambda_arn : null
      post_authentication = var.enable_post_authentication ? var.post_authentication_lambda_arn : null
      custom_message      = var.enable_custom_message ? var.custom_message_lambda_arn : null
    }
  }

  dynamic "verification_message_template" {
    for_each = var.verification_message_template != null ? [1] : []
    content {
      default_email_option  = var.verification_message_template.default_email_option
      email_subject         = var.verification_message_template.email_subject
      email_message         = var.verification_message_template.email_message
      email_message_by_link = var.verification_message_template.email_message_by_link
      sms_message           = var.verification_message_template.sms_message
    }
  }

  dynamic "admin_create_user_config" {
    for_each = var.admin_create_user_config != null ? [var.admin_create_user_config] : []
    content {
      allow_admin_create_user_only = admin_create_user_config.value.allow_admin_create_user_only

      dynamic "invite_message_template" {
        for_each = admin_create_user_config.value.invite_message_template != null ? [admin_create_user_config.value.invite_message_template] : []
        content {
          email_subject = invite_message_template.value.email_subject
          email_message = invite_message_template.value.email_message
          sms_message   = invite_message_template.value.sms_message
        }
      }
    }
  }

  dynamic "email_configuration" {
    for_each = var.email_configuration != null ? [var.email_configuration] : []

    content {
      email_sending_account  = email_configuration.value.email_sending_account
      source_arn             = email_configuration.value.source_arn
      from_email_address     = email_configuration.value.from_email_address
      reply_to_email_address = email_configuration.value.reply_to_email_address
    }
  }

}

# DEPRECATED: Use `var.clients` + `aws_cognito_user_pool_client.clients` instead.
# Kept only for backward compatibility with older module consumers.
resource "aws_cognito_user_pool_client" "this" {
  count = (var.client_name != null && !var.enable_google_idp) ? 1 : 0

  name = var.client_name

  user_pool_id            = aws_cognito_user_pool.this.id
  generate_secret         = var.client_generate_secret
  enable_token_revocation = true

  token_validity_units {
    access_token  = var.access_token_validity_unit
    id_token      = var.id_token_validity_unit
    refresh_token = var.refresh_token_validity_unit
  }
  access_token_validity         = var.access_token_validity
  id_token_validity             = var.id_token_validity
  refresh_token_validity        = var.refresh_token_validity
  prevent_user_existence_errors = var.prevent_user_existence_errors
  explicit_auth_flows           = var.explicit_auth_flows

}

# DEPRECATED: Use `var.clients` + `aws_cognito_user_pool_client.clients`
# with `supported_identity_providers = [\"COGNITO\", \"Google\"]` instead.
# Kept only for backward compatibility with older module consumers.
resource "aws_cognito_user_pool_client" "google" {
  count = (var.client_name != null && var.enable_google_idp) ? 1 : 0

  name         = "${var.client_name}-google"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret         = var.client_generate_secret
  explicit_auth_flows     = var.explicit_auth_flows
  enable_token_revocation = true

  # Hosted UI + Google için zorunlu alanlar
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  allowed_oauth_flows_user_pool_client = true

  supported_identity_providers = ["COGNITO", "Google"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  refresh_token_validity = var.refresh_token_validity

  token_validity_units {
    access_token  = var.access_token_validity_unit
    id_token      = var.id_token_validity_unit
    refresh_token = var.refresh_token_validity_unit
  }
}

# Preferred multi-client support (backward compatible with legacy clients above)
resource "aws_cognito_user_pool_client" "clients" {
  for_each = { for idx, client in var.clients : client.name => client }

  name         = each.value.name
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret         = each.value.generate_secret
  explicit_auth_flows     = each.value.explicit_auth_flows
  enable_token_revocation = each.value.enable_token_revocation

  access_token_validity         = each.value.access_token_validity
  id_token_validity             = each.value.id_token_validity
  refresh_token_validity        = each.value.refresh_token_validity
  prevent_user_existence_errors = each.value.prevent_user_existence_errors

  token_validity_units {
    access_token  = each.value.access_token_validity_unit
    id_token      = each.value.id_token_validity_unit
    refresh_token = each.value.refresh_token_validity_unit
  }

  # OAuth settings (optional, only if provided)
  allowed_oauth_flows                  = each.value.allowed_oauth_flows
  allowed_oauth_scopes                 = each.value.allowed_oauth_scopes
  allowed_oauth_flows_user_pool_client = each.value.allowed_oauth_flows_user_pool_client
  supported_identity_providers         = each.value.supported_identity_providers
  callback_urls                        = each.value.callback_urls
  logout_urls                          = each.value.logout_urls
}

# Check if any client uses Google IDP
locals {
  clients_using_google = [
    for client in var.clients :
    client if client.supported_identity_providers != null && contains(client.supported_identity_providers, "Google")
  ]
  has_google_client = var.enable_google_idp || length(local.clients_using_google) > 0
}

resource "aws_cognito_identity_provider" "google" {
  count = local.has_google_client ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "openid email profile"
  }

  attribute_mapping = {
    email = "email"
    name  = "name"
  }
}


resource "aws_cognito_user_pool_domain" "this" {
  count = local.has_google_client && var.cognito_domain_prefix != null ? 1 : 0

  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.this.id
}



# Allow Cognito to invoke the Pre Token Generation Lambda when configured
resource "aws_lambda_permission" "pre_token_generation_invoke" {
  count = var.enable_pre_token_generation ? 1 : 0

  statement_id  = "AllowExecutionFromCognitoPreTokenGeneration"
  action        = "lambda:InvokeFunction"
  function_name = var.pre_token_generation_lambda_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn

  depends_on = [
    aws_cognito_user_pool.this
  ]
}

# Allow Cognito to invoke the Post Confirmation Lambda when configured
resource "aws_lambda_permission" "post_confirmation_invoke" {
  count = var.enable_post_confirmation ? 1 : 0

  statement_id  = "AllowExecutionFromCognitoPostConfirmation"
  action        = "lambda:InvokeFunction"
  function_name = var.post_confirmation_lambda_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn

  depends_on = [
    aws_cognito_user_pool.this
  ]
}

# Allow Cognito to invoke the Post Authentication Lambda when configured
resource "aws_lambda_permission" "post_authentication_invoke" {
  count = var.enable_post_authentication ? 1 : 0

  statement_id  = "AllowExecutionFromCognitoPostAuthentication"
  action        = "lambda:InvokeFunction"
  function_name = var.post_authentication_lambda_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn

  depends_on = [
    aws_cognito_user_pool.this
  ]
}

# Allow Cognito to invoke the Custom Message Lambda when configured
resource "aws_lambda_permission" "custom_message_invoke" {
  count = var.enable_custom_message ? 1 : 0

  statement_id  = "AllowExecutionFromCognitoCustomMessage"
  action        = "lambda:InvokeFunction"
  function_name = var.custom_message_lambda_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn

  depends_on = [
    aws_cognito_user_pool.this
  ]
}

resource "aws_iam_policy" "admin_policy" {
  name        = "${var.user_pool_name}-AdminPolicy"
  description = "Allows admin access to Cognito"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "cognito-identity:*",
            "cognito-idp:*",
            "cognito-sync:*",
            "iam:ListRoles",
            "iam:ListOpenIdConnectProviders",
            "sns:ListPlatformApplications"
          ],
          "Resource" : "${aws_cognito_user_pool.this.arn}"
        }
      ]
    }
  )

}
