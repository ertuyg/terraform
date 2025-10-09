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

Creates a Cognito User Pool and Client with configurable password policy, schema, recovery settings, and token validity. Supports optional Pre Token Generation trigger.

Key inputs (see `cognito/variables.tf` for full list):

- `user_pool_name` (string): User pool name
- `client_name` (string): App client name
- `username_attributes` (list(string)) default `["email"]`
- `auto_verified_attributes` (list(string)) default `["email"]`
- Password policy inputs: `minimum_length`, `require_lowercase`, `require_numbers`, `require_symbols`, `require_uppercase`, `temporary_password_validity_days`
- Token validity inputs: `access_token_validity_unit`, `access_token_validity`, `id_token_validity_unit`, `id_token_validity`, `refresh_token_validity_unit`, `refresh_token_validity`
- `explicit_auth_flows` (list(string))
- `schema` and `recovery_mechanism` (advanced)
- Pre Token Generation trigger:
  - `enable_pre_token_generation` (bool): Explicitly enable trigger resources (default `false`)
  - `pre_token_generation_lambda_arn` (string|null): Lambda ARN to enable trigger (optional)
  - `pre_token_generation_lambda_version` (string): `V1_0` or `V2_0` (default `V2_0`)

Outputs (see `cognito/outputs.tf`):

- `user_pool_id`
- `user_pool_client_id`
- `user_pool_arn`
- `user_pool_issuer`
- `admin_policy_arn`

Example `terraform.tfvars`:

```hcl
user_pool_name  = "my-user-pool"
client_name     = "my-web-client"

# Optional Pre Token Generation trigger
enable_pre_token_generation         = true
pre_token_generation_lambda_arn     = "arn:aws:lambda:eu-central-1:123456789012:function:pre-token-customizer"
pre_token_generation_lambda_version = "V2_0"
```

Notes:

- When `enable_pre_token_generation = true`, the module configures `lambda_config.pre_token_generation_config` and grants invoke permission to Cognito via `aws_lambda_permission`. Use this flag to avoid plan-time indeterminism if your Lambda ARN is computed.

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

Creates a CloudFront distribution. Often used with `s3` as an origin and ACM for HTTPS.

Typical inputs:

- `distribution_comment` (string)
- `origins` (list(object)) – domain name, origin ID, optional OAC/OAI
- `default_cache_behavior` (object)
- `viewer_certificate` (object) – ACM cert ARN and SSL settings
- `price_class` (string)

Outputs:

- Distribution ID/ARN and domain name

Example `terraform.tfvars`:

```hcl
distribution_comment = "web-static"
price_class          = "PriceClass_100"
# origins, cache behaviors, viewer_certificate per your needs
```

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
