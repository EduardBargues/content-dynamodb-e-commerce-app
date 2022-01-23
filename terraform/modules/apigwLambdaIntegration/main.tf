resource "aws_api_gateway_method" "main" {
  rest_api_id   = var.apigw_id
  resource_id   = var.resource_id
  http_method   = var.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id             = var.apigw_id
  resource_id             = var.resource_id
  http_method             = aws_api_gateway_method.main.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.invoke_arn
}

resource "aws_lambda_permission" "create_customer" {
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = var.source_arn
}
