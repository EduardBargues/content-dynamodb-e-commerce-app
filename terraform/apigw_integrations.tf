locals {
  integrations = {
    CreateCustomer = {
      http_method = "POST"
      resource_id = aws_api_gateway_resource.customers.id
      path        = aws_api_gateway_resource.customers.path
    }
    CreateOrder = {
      http_method = "POST"
      resource_id = aws_api_gateway_resource.orders.id
      path        = aws_api_gateway_resource.orders.path
    }
    GetCustomerWithRecentOrders = {
      http_method = "GET"
      resource_id = aws_api_gateway_resource.customer_name.id
      path        = aws_api_gateway_resource.customer_name.path
    }
    GetOrder = {
      http_method = "GET"
      resource_id = aws_api_gateway_resource.order_id.id
      path        = aws_api_gateway_resource.order_id.path
    }
    UpdateCustomerAddresses = {
      http_method = "PUT"
      resource_id = aws_api_gateway_resource.customer_name.id
      path        = aws_api_gateway_resource.customer_name.path
    }
  }
}

module "apigw_integrations" {
  source = "./modules/apigwLambdaIntegration"

  for_each = local.integrations

  http_method   = each.value.http_method
  function_name = module.lambdas[each.key].function_name
  invoke_arn    = module.lambdas[each.key].invoke_arn
  apigw_id      = aws_api_gateway_rest_api.api.id
  resource_id   = each.value.resource_id
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.api.id}/*/${each.value.http_method}${each.value.path}"
}
