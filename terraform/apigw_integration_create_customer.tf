resource "aws_api_gateway_method" "create_customer" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.customers.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_customer" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.customers.id
  http_method             = aws_api_gateway_method.create_customer.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_customer.invoke_arn
}

resource "aws_lambda_permission" "create_customer" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_customer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.create_customer.http_method}${aws_api_gateway_resource.customers.path}"
}
