
resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes
  password_policy {
    minimum_length                   = var.minimum_length
    require_lowercase                = var.require_lowercase
    require_numbers                  = var.require_numbers
    require_symbols                  = var.require_symbols
    require_uppercase                = var.require_uppercase
    temporary_password_validity_days = var.temporary_password_validity_days
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
    for_each = var.enable_pre_token_generation ? [1] : []
    content {
      pre_token_generation_config {
        lambda_arn     = var.pre_token_generation_lambda_arn
        lambda_version = var.pre_token_generation_lambda_version
      }
    }
  }

}

resource "aws_cognito_user_pool_client" "this" {
  count = var.enable_google_idp ? 0 : 1

  name = var.client_name

  user_pool_id    = aws_cognito_user_pool.this.id
  generate_secret = var.client_generate_secret

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

resource "aws_cognito_user_pool_client" "google" {
  count = var.enable_google_idp ? 1 : 0

  name         = "${var.client_name}-google"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = var.client_generate_secret
  explicit_auth_flows = var.explicit_auth_flows

  # Hosted UI + Google için zorunlu alanlar
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["openid", "email", "profile"]
  allowed_oauth_flows_user_pool_client = true

  supported_identity_providers = ["COGNITO", "Google"]

  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  access_token_validity         = var.access_token_validity
  id_token_validity             = var.id_token_validity
  refresh_token_validity        = var.refresh_token_validity

  token_validity_units {
    access_token  = var.access_token_validity_unit
    id_token      = var.id_token_validity_unit
    refresh_token = var.refresh_token_validity_unit
  }
}

resource "aws_cognito_identity_provider" "google" {
  count = var.enable_google_idp ? 1 : 0

  user_pool_id = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id       = var.google_client_id
    client_secret   = var.google_client_secret
    authorize_scopes = "openid email profile"
  }

  attribute_mapping = {
    email = "email"
    name  = "name"
  }
}


resource "aws_cognito_user_pool_domain" "this" {
  count       = var.enable_google_idp && var.cognito_domain_prefix != null ? 1 : 0

  domain      = var.cognito_domain_prefix
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
