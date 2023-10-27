
provider "aws" {
  # profile = "galenos-tf-admin"
  region = var.aws_region
}


module "lambda" {
  source        = "./modules/lambda"
  for_each      = local.lambda_configs
  function_name = "${var.api_name}_${var.stage}_${var.version_number}_${each.key}"
  source_path   = "${var.dist_root_dir}/${each.value.source_dir}"
  handler       = lookup(each.value, "handler", "${each.value.source_file}.handler")
  runtime       = lookup(each.value, "runtime", "nodejs16.x")
  db_policies   = lookup(each.value, "db_policies", {})
  # environment_variables = {
  #   STAGE = var.stage
  # }
  # layers = [module.lambda_layers.layer_arns["common"]]
}

module "apigateway" {
  source   = "./modules/apigw"
  api_name = var.api_name
  stage    = var.stage
  routes   = local.lambdas_for_apigw
  # routes = {
  #   for name, config in local.lambda_configs : name => {
  #     invoke_arn           = module.lambda[name].invoke_arn
  #     lambda_function_name = name
  #     route                = config.route_key
  #     http_method          = config.http_method
  #     use_authorization    = lookup(config, "authorization_type", false)

  #   } if config.integrate_with_api
  # }  
  # lambda_invoke_arns = module.lambda.lambda_invoke_arns
}


module "dynamodb" {
  source     = "./modules/dynamodb"
  for_each   = local.dynamodb_tables
  table_name = each.value.table_name
}


###### FOREACH'li versiyonlar da kullanılabilir ######
# module "lambda_layers" {
#   source = "./modules/layers"
#   layers = [
#     {
#       name                = "common"
#       source_path         = "../../dist/layers/common"
#       description         = "Description for my first layer"
#       compatible_runtimes = ["nodejs16.x"]
#     },
#     # ... Diğer katmanlar
#   ]
# }

# module "lambda_with_apigw" {
#   source               = "./modules/lambda_with_apigw"
#   api_name             = "MyAPI"
#   stage                = "dev"
#   db_modify_policies   = module.dynamodb.modify_policies
#   db_readonly_policies = module.dynamodb.readonly_policies
#   lambda_configurations = [
#     {
#       function_name = "projects_get"
#       runtime       = "nodejs16.x"
#       handler       = "get.handler"
#       source_path   = "../../dist/projects"
#       # environment   = map(string)

#       integrate_with_api = true
#       http_method        = "GET"
#       route              = "/projects/get"
#       use_authorization  = false
#       # ... diğer ayarlar ...
#       dynamodb_access = [
#         {
#           table_name  = module.dynamodb.dynamodb_table_names["projects"]
#           access_type = "readonly"
#         },
#         {
#           table_name  = module.dynamodb.dynamodb_table_names["projects"]
#           access_type = "modify"
#       }]
#       layers = [module.lambda_layers.layer_arns["common"]]
#     },
#     # ... Diğer fonksiyonlar
#   ]
# }

# module "dynamodb" {
#   source = "./modules/dynamodb"
#   tables = [
#     {
#       table_name               = "projects"
#       hash_key                 = "PK"
#       hash_key_type            = "S"
#       range_key                = "SK"
#       range_key_type           = "S"
#       billing_mode             = "PAY_PER_REQUEST"
#       additional_attributes    = []
#       global_secondary_indexes = []
#       # additional_attributes = [
#       #   {
#       #     name = "entity"
#       #     type = "S"
#       #   }
#       # ]
#     },
#     # {
#     #   table_name          = "Table2"
#     #   hash_key            = "PK2"
#     #   range_key           = "SK2"
#     #   billing_mode        = "PROVISIONED"
#     #   read_capacity_units = 5
#     #   write_capacity_units= 5
#     # }
#     # # ... Diğer tablolar ...
#   ]
# }
