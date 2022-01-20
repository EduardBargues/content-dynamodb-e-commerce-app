resource "aws_api_gateway_method" "update_customer_addresses" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.customer_name.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "update_customer_addresses" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.customer_name.id
  http_method             = aws_api_gateway_method.update_customer_addresses.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_customer_addresses.invoke_arn
}

resource "aws_lambda_permission" "update_customer_addresses" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_customer_addresses.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.update_customer_addresses.http_method}${aws_api_gateway_resource.customer_name.path}"
}
