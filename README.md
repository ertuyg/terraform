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
pre_token_generation_lambda_arn     = "arn:aws:lambda:eu-central-1:123456789012:function:pre-token-customizer"
pre_token_generation_lambda_version = "V2_0"
```

Notes:

- When `pre_token_generation_lambda_arn` is set, the module configures `lambda_config.pre_token_generation_config` and grants invoke permission to Cognito via `aws_lambda_permission`.

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

Packages and publishes a Lambda Layer from a local directory.

Inputs typically include layer name, description, compatible runtimes, and source path (directory or zip). Use the resulting Layer ARN in the `lambda` stack via the `layers` input.

#### 4) `apigw`

Creates an API Gateway (config details depend on the stack). Typically you’ll wire Lambda integrations by passing Lambda ARNs or via IAM permissions. Check the stack’s `variables.tf` for inputs and provide your `terraform.tfvars` accordingly.

#### 5) `cloudfront`

Creates a CloudFront distribution. Often used together with `s3` (as an origin) and `acm` (not shown here) for SSL. Configure origins, behaviors, and optional OAC/OAI as exposed by the stack’s inputs.

#### 6) `s3`

Creates S3 bucket(s). Provide bucket names, versioning, encryption, public access block, lifecycle, etc., via the stack inputs.

#### 7) `dynamodb`

Creates DynamoDB table(s). Configure table name(s), hash/range keys, billing mode, TTL, GSIs/LSIs via inputs.

#### 8) `sns`

Creates SNS topic(s) and optional subscriptions. Use the topic ARNs to publish from Lambda or other services.

#### 9) `sqs`

Creates SQS queue(s) (standard or FIFO) with visibility timeout, DLQ config, redrive policies, etc.

#### 10) `iam`

Defines IAM roles and/or policies used across services. You can attach these policies to Lambdas or other resources as needed.

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
