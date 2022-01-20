resource "aws_api_gateway_method" "get_customer_with_recent_orders" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.customer_name.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_customer_with_recent_orders" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.customer_name.id
  http_method             = aws_api_gateway_method.get_customer_with_recent_orders.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_customer_with_recent_orders.invoke_arn
}

resource "aws_lambda_permission" "get_customer_with_recent_orders" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_customer_with_recent_orders.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.get_customer_with_recent_orders.http_method}${aws_api_gateway_resource.customer_name.path}"
}
