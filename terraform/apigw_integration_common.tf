resource "aws_api_gateway_resource" "customers" {
  path_part   = local.customers
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_resource" "customer_name" {
  path_part   = "{customerName}"
  parent_id   = aws_api_gateway_resource.customers.id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_resource" "orders" {
  path_part   = local.orders
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}
resource "aws_api_gateway_resource" "order_id" {
  path_part   = "{orderId}"
  parent_id   = aws_api_gateway_resource.orders.id
  rest_api_id = aws_api_gateway_rest_api.api.id
}
