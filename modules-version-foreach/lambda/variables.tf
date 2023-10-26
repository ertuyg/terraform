variable "lambda_configurations" {
  description = "Configuration for Lambda functions and their API Gateway integrations"
  type = list(object({
    function_name = string
    runtime       = string
    handler       = string
    source_path   = string
    environment   = optional(map(string))

    layers = optional(list(string))

  }))
}

#  layer kullanımı    layers = [module.layers.layer_arns["layer1"], module.layers.layer_arns["layer2"]]
