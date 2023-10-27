locals {
  lambda_configs = {
    projects_get = {
      source_dir         = "projects"
      source_file        = "get"
      http_method        = "GET"
      route_key          = "projects"
      layers             = ["layer_common"]
      integrate_with_api = true
      db_policies = {
        projects = module.dynamodb["projects"].readwrite_policy_arn,
        services = module.dynamodb["services"].readonly_policy_arn
      }
      #   db_configs = [
      #     {
      #       table_name = "projects",
      #       policy_arn = module.dynamodb["projects"].readwrite_policy_arn
      #     },
      #     {
      #       table_name = "services",
      #       policy_arn = module.dynamodb["services"].readonly_policy_arn
      #     }
      #   ]
      #   role               = "db_readonly"
      #   authorization_type = "JWT"
    },
    services_get = {
      source_dir         = "projects"
      source_file        = "get"
      http_method        = "GET"
      route_key          = "services"
      layers             = ["layer_common"]
      integrate_with_api = true
    },
    onlylambda = {
      source_dir  = "onlylambda"
      source_file = "index"
      http_method = "GET"
      #   route_key          = "projects"
      #   layers             = ["layer_common"]
      integrate_with_api = false
    }

  }

  lambdas_for_apigw = {
    for name, config in local.lambda_configs : name => {
      invoke_arn           = module.lambda[name].invoke_arn
      lambda_function_name = "${var.api_name}_${var.stage}_${var.version_number}_${name}"
      route_key            = config.route_key
      http_method          = config.http_method
      use_authorization    = lookup(config, "authorization_type", false)
    } if config.integrate_with_api
  }
  dynamodb_tables = {
    projects = {
      table_name = "projects"
    },
    services = {
      table_name = "services"
    }
  }
}
