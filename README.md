### Terraform AWS Infrastructure – Modules Guide

This repository contains self-contained Terraform stacks for common AWS components. Each directory under the repo root is a deployable stack you can `init/plan/apply` independently.

Modules/stacks included:

- `apigw`: Amazon API Gateway
- `cloudfront`: Amazon CloudFront
- `cognito`: Amazon Cognito User Pool and Client
- `dynamodb`: Amazon DynamoDB
- `iam`: IAM roles/policies
- `lambda`: AWS Lambda function (packaged from local source)
- `lambda-layer`: AWS Lambda layer
- `s3`: Amazon S3 bucket(s)
- `sns`: Amazon SNS topics
- `sqs`: Amazon SQS queues

#### Prerequisites

- Terraform >= 1.3
- AWS credentials configured (env vars, shared config, or SSO)
- AWS account permissions to create the resources above

#### How to use

Each stack is independent. To deploy one:

1. Change directory

```bash
cd <stack>
```

2. Create a `terraform.tfvars` (or pass `-var/-var-file`) with required inputs
3. Plan and apply

```bash
terraform init
terraform plan
terraform apply
```

To destroy a stack:

```bash
terraform destroy
```

Tip: Use Terraform workspaces if you need multiple environments:

```bash
terraform workspace new dev
terraform workspace select dev
```

---

### Module/Stack Details

#### 1) `cognito`

Creates a Cognito User Pool and Client with configurable password policy, schema, recovery settings, and token validity. Supports optional Pre Token Generation, Post Confirmation, and Post Authentication triggers, and Google Identity Provider (IDP) integration with Hosted UI.

Key inputs (see `cognito/variables.tf` for full list):

- `user_pool_name` (string): User pool name
- `client_name` (string): App client name
- `username_attributes` (list(string)) default `["email"]`
- `auto_verified_attributes` (list(string)) default `["email"]`
- `enable_email_verification` (bool): Enable email verification, ensures email is in auto_verified_attributes (default `false`)
- Password policy inputs: `minimum_length`, `require_lowercase`, `require_numbers`, `require_symbols`, `require_uppercase`, `temporary_password_validity_days`
- Token validity inputs: `access_token_validity_unit`, `access_token_validity`, `id_token_validity_unit`, `id_token_validity`, `refresh_token_validity_unit`, `refresh_token_validity`
- `explicit_auth_flows` (list(string))
- `schema` and `recovery_mechanism` (advanced)
- Pre Token Generation trigger:
  - `enable_pre_token_generation` (bool): Explicitly enable trigger resources (default `false`)
  - `pre_token_generation_lambda_arn` (string|null): Lambda ARN to enable trigger (optional)
  - `pre_token_generation_lambda_version` (string): `V1_0` or `V2_0` (default `V2_0`)
- Post Confirmation trigger:
  - `enable_post_confirmation` (bool): Explicitly enable trigger resources (default `false`)
  - `post_confirmation_lambda_arn` (string|null): Lambda ARN to enable trigger (optional)
- Post Authentication trigger:
  - `enable_post_authentication` (bool): Explicitly enable trigger resources (default `false`)
  - `post_authentication_lambda_arn` (string|null): Lambda ARN to enable trigger (optional)
- Verification message template (optional):
  - `verification_message_template` (object|null): Custom verification message template
    - `default_email_option` (string): `CONFIRM_WITH_CODE` or `CONFIRM_WITH_LINK` (default `CONFIRM_WITH_CODE`)
    - `email_subject` (string|null): Custom email subject
    - `email_message` (string|null): Custom email message (use `{####}` placeholder for code)
    - `email_message_by_link` (string|null): Custom email message for link verification (use `{##Verify Email##}` placeholder)
    - `sms_message` (string|null): Custom SMS message (use `{####}` placeholder for code)
- Google Identity Provider (optional):
  - `enable_google_idp` (bool): Enable Google as an identity provider (default `false`)
  - `google_client_id` (string|null, sensitive): Google OAuth client ID
  - `google_client_secret` (string|null, sensitive): Google OAuth client secret
  - `callback_urls` (list(string)): OAuth callback URLs for Hosted UI (e.g., `["https://example.com/auth/callback"]`)
  - `logout_urls` (list(string)): OAuth logout URLs for Hosted UI (e.g., `["https://example.com/"]`)
  - `cognito_domain_prefix` (string|null): Domain prefix for Cognito Hosted UI (e.g., `"my-app-auth"`)

Outputs (see `cognito/outputs.tf`):

- `user_pool_id`
- `user_pool_client_id` (returns Google client ID when Google IDP is enabled, otherwise standard client ID)
- `user_pool_arn`
- `user_pool_issuer`
- `admin_policy_arn`
- `cognito_domain` (only when Google IDP and domain prefix are configured)

Example `terraform.tfvars` (basic):

```hcl
user_pool_name  = "my-user-pool"
client_name     = "my-web-client"

# Optional Pre Token Generation trigger
enable_pre_token_generation         = true
pre_token_generation_lambda_arn     = "arn:aws:lambda:eu-central-1:123456789012:function:pre-token-customizer"
pre_token_generation_lambda_version = "V2_0"

# Optional verification message template
verification_message_template = {
  default_email_option = "CONFIRM_WITH_CODE"
  email_subject         = "Your verification code"
  email_message         = "Your verification code is {####}"
  sms_message          = "Your verification code is {####}"
}
```

Example `terraform.tfvars` (with Google IDP):

```hcl
user_pool_name  = "my-user-pool"
client_name     = "my-web-client"

# Enable Google Identity Provider
enable_google_idp     = true
google_client_id      = "your-google-client-id.apps.googleusercontent.com"
google_client_secret  = "your-google-client-secret"
callback_urls         = ["https://example.com/auth/callback"]
logout_urls           = ["https://example.com/"]
cognito_domain_prefix = "my-app-auth"
```

Notes:

- When `enable_email_verification = true` (default), the module ensures that `email` is included in `auto_verified_attributes`, enabling automatic email verification for new users.
- When `verification_message_template` is provided, the module configures custom verification messages for email and SMS. Use placeholders: `{####}` for verification code, `{##Verify Email##}` for verification link.
- When `enable_pre_token_generation = true`, the module configures `lambda_config.pre_token_generation_config` and grants invoke permission to Cognito via `aws_lambda_permission`. Use this flag to avoid plan-time indeterminism if your Lambda ARN is computed.
- When `enable_post_confirmation = true`, the module configures `lambda_config.post_confirmation` and grants invoke permission to Cognito via `aws_lambda_permission`. This trigger is invoked after a user confirms their account (email or phone verification).
- When `enable_post_authentication = true`, the module configures `lambda_config.post_authentication` and grants invoke permission to Cognito via `aws_lambda_permission`. This trigger is invoked after a user successfully authenticates (signs in).
- When `enable_google_idp = true`, the module creates a separate Cognito client configured for Hosted UI with OAuth flows, a Google identity provider, and optionally a Cognito domain for the Hosted UI. The `user_pool_client_id` output automatically returns the Google client ID when enabled.
- The Cognito domain is only created when both `enable_google_idp = true` and `cognito_domain_prefix` is provided.

#### 2) `lambda`

Packages a Lambda function from a local directory or zip and creates required IAM role/policy attachments, environment variables, and a CloudWatch Logs group.

Key inputs (typical):

- `function_name` (string)
- `handler` (string) – e.g., `index.handler`
- `runtime` (string) – e.g., `nodejs20.x`, `python3.11`, etc.
- `source_path` (string) – either a directory (zipped) or a single zip file path
- `lambda_timeout` (number) – function timeout seconds
- `environment_variables` (map(string))
- `policy_attachments` (map(string)) – managed policy ARNs keyed by name
- `layers` (list(string)) – optional layer ARNs
- `log_retention` (number) – CloudWatch log retention days

Outputs: expose the Lambda function and role ARNs/names if defined in the module (check the stack implementation).

Example `terraform.tfvars`:

```hcl
function_name         = "pre-token-customizer"
handler               = "index.handler"
runtime               = "nodejs20.x"
source_path           = "./src/pre-token-customizer" # or a .zip
lambda_timeout        = 10
environment_variables = { STAGE = "dev" }
policy_attachments    = { basic = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole" }
layers                = []
log_retention         = 14
```

Tip: If you want Cognito to call this function as the Pre Token Generation trigger, set the Lambda ARN in the `cognito` stack’s `pre_token_generation_lambda_arn`.

#### 3) `lambda-layer`

Packages and publishes a Lambda Layer from a local directory or zip.

Typical inputs:

- `layer_name` (string)
- `description` (string)
- `compatible_runtimes` (list(string)) – e.g., `["nodejs20.x", "python3.11"]`
- `source_path` (string) – directory to package or a prebuilt zip
- `license_info` (string) – optional

Outputs:

- Layer ARN and version (as defined by the stack)

Example `terraform.tfvars`:

```hcl
layer_name          = "common-deps"
description         = "Shared libraries"
compatible_runtimes = ["nodejs20.x"]
source_path         = "./layers/common-deps"
```

#### 4) `apigw`

Creates an API Gateway. You typically wire Lambda integrations by passing Lambda ARNs and enabling IAM permissions.

Typical inputs:

- `api_name` (string)
- `stage_name` (string)
- `description` (string)
- `endpoint_type` (string) – e.g., `REGIONAL`
- Integration inputs (Lambda ARNs, routes) as exposed by the stack

Outputs:

- API ID/ARN, invoke URL, stage variables (as defined by the stack)

Example `terraform.tfvars`:

```hcl
api_name     = "my-api"
stage_name   = "dev"
endpoint_type = "REGIONAL"
```

#### 5) `cloudfront`

Creates a CloudFront distribution with support for multiple S3 origins and dynamic cache behaviors. Features automatic Origin Access Control (OAC) creation and backward compatibility with legacy single-origin setup.

**Key Features:**

- Multi-origin support (multiple S3 buckets)
- Dynamic ordered cache behaviors per path pattern
- Automatic OAC creation with custom naming
- Support for existing OAC resources
- Backward compatible with legacy single-origin mode

**Typical inputs:**

- **Legacy Mode (single origin):**

  - `bucket_name` (string): S3 bucket name
  - `s3_origin_id` (string): Origin identifier
  - `origin_access_control_name` (string): OAC name

- **Multi-Origin Mode:**

  - `origins` (list(object)): List of S3 origins
    - `bucket_name` (required)
    - `origin_id` (required)
    - `origin_path` (optional)
    - `origin_access_control_name` (optional, auto-generated if not provided)
    - `origin_access_control_id` (optional, use existing OAC)
  - `ordered_cache_behaviors` (list(object)): Cache behaviors per path
    - `path_pattern`, `target_origin_id`, `viewer_protocol_policy`
    - `compress`, `allowed_methods`, TTL settings
    - `query_string`, `cookies_forward`

- **Common:**
  - `aliases` (list(string)): Custom domain names
  - `Environment` (string): Environment tag

**Outputs:**

- `cloudfront_distribution_id`
- `cloudfront_distribution_arn`
- `cloudfront_distribution_domain_name`

**Example `terraform.tfvars` (Legacy):**

```hcl
bucket_name                = "my-static-site"
s3_origin_id               = "S3-my-bucket"
origin_access_control_name = "my-oac"
aliases                    = ["www.example.com"]
```

**Example `terraform.tfvars` (Multi-Origin):**

```hcl
origins = [
  {
    bucket_name = "images-bucket"
    origin_id   = "S3-images"
    # OAC auto-created as "S3-images-oac"
  },
  {
    bucket_name = "videos-bucket"
    origin_id   = "S3-videos"
  }
]

ordered_cache_behaviors = [
  {
    path_pattern           = "/images/*"
    target_origin_id       = "S3-images"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 86400  # 1 day
  },
  {
    path_pattern     = "/videos/*"
    target_origin_id = "S3-videos"
    compress         = false
    min_ttl          = 3600  # 1 hour
  }
]

aliases = ["cdn.example.com"]
```

**Notes:**

- S3 buckets must exist before applying (module doesn't create buckets)
- Each origin gets automatic S3 bucket policy for CloudFront access
- See `cloudfront/README.md` for detailed documentation and more examples

#### 6) `s3`

Creates S3 bucket(s) with common options.

Typical inputs:

- `bucket_name` (string)
- `versioning_enabled` (bool)
- `server_side_encryption` (object)
- `block_public_access` (bool)
- `lifecycle_rules` (list(object))

Outputs:

- Bucket name, ARN, domain name

Example `terraform.tfvars`:

```hcl
bucket_name          = "my-static-site-bucket"
versioning_enabled   = true
block_public_access  = true
```

#### 7) `dynamodb`

Creates DynamoDB table(s) with indexes and TTL.

Typical inputs:

- `table_name` (string)
- `billing_mode` (string) – `PAY_PER_REQUEST` or `PROVISIONED`
- `hash_key` (string)
- `range_key` (string|null)
- `attributes` (list(object)) – name/type definitions
- `ttl` (object) – attribute name and enabled flag
- `global_secondary_indexes` / `local_secondary_indexes`

Outputs:

- Table name, ARN, stream ARN

Example `terraform.tfvars`:

```hcl
table_name   = "users"
billing_mode = "PAY_PER_REQUEST"
hash_key     = "userId"
attributes = [
  { name = "userId", type = "S" }
]
```

#### 8) `sns`

Creates SNS topic(s) and optional subscriptions.

Typical inputs:

- `topics` (list(object)) – name, display name
- `subscriptions` (list(object)) – protocol, endpoint, topic

Outputs:

- Topic ARNs

Example `terraform.tfvars`:

```hcl
topics = [
  { name = "alerts", display_name = "Alerts" }
]
```

#### 9) `sqs`

Creates SQS queue(s) with DLQ and redrive policies.

Typical inputs:

- `queues` (list(object)) – name, fifo, visibility timeout, message retention
- `redrive_policies` (list(object)) – DLQ wiring

Outputs:

- Queue URLs and ARNs

Example `terraform.tfvars`:

```hcl
queues = [
  { name = "jobs", fifo = false, visibility_timeout_seconds = 30 }
]
```

#### 10) `iam`

Defines IAM roles and/or policies used across services.

Typical inputs:

- `policies` (map(string|object)) – inline or managed policies to create/attach
- `roles` (list(object)) – assume role policy docs, attached policies

Outputs:

- Role names/ARNs and policy ARNs

Example `terraform.tfvars`:

```hcl
# Example: no-op or define policies/roles as your stack exposes
```

---

### Cross-stack wiring

These stacks are designed to be deployed independently. You can compose them in a higher-level project either by:

- Referencing outputs directly within a monorepo root module that calls each as a module, or
- Using Terraform remote state data sources to read outputs from another stack.

Examples:

- Use `lambda` output ARN as `pre_token_generation_lambda_arn` in `cognito`.
- Use `s3` bucket domain/ARN as a CloudFront origin in `cloudfront`.
- Attach `iam` policies to a `lambda` function through `policy_attachments`.

---

### Conventions and tips

- Keep each stack’s `terraform.tfvars` minimal and environment-specific.
- Prefer Terraform workspaces or separate state files per environment.
- For production, consider enabling state locking (e.g., S3 + DynamoDB backend) and CI/CD.
- Run `terraform fmt` and `terraform validate` before applying changes.

---

### Troubleshooting

- Permission errors: verify AWS credentials and IAM permissions.
- Lambda packaging: ensure `source_path` points to a valid directory or zip; handler and runtime match your code.
- Cognito Pre Token trigger: the Lambda must exist, and the ARN must be correct (optionally alias/version). The stack automatically grants `lambda:InvokeFunction` permission from `cognito-idp.amazonaws.com` for the user pool.
