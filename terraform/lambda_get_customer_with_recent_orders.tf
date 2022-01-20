locals {
  get_customer_with_recent_orders_file_name = "GetCustomerWithRecentOrders.zip"
}
resource "aws_lambda_function" "get_customer_with_recent_orders" {
  function_name    = "${local.prefix}-get-customer-with-recent-orders"
  filename         = local.get_customer_with_recent_orders_file_name
  source_code_hash = filebase64sha256(local.get_customer_with_recent_orders_file_name)
  handler          = "GetCustomerWithRecentOrders::GetCustomerWithRecentOrders.Function::Handler"
  runtime          = "dotnetcore3.1"
  memory_size      = 256
  timeout          = 30
  role             = aws_iam_role.get_customer_with_recent_orders.arn

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.main.name
    }
  }
}

resource "aws_iam_role" "get_customer_with_recent_orders" {
  name = "${local.prefix}-get-customer-with-recent-orders"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "get_customer_with_recent_orders_dynamodb" {
  name = aws_lambda_function.get_customer_with_recent_orders.function_name
  role = aws_iam_role.get_customer_with_recent_orders.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "dynamodb:Query"
      ],
      "Resource" : "${aws_dynamodb_table.main.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "get_customer_with_recent_orders" {
  role       = aws_iam_role.get_customer_with_recent_orders.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "get_customer_with_recent_orders" {
  name              = "/aws/lambda/${aws_lambda_function.get_customer_with_recent_orders.function_name}"
  retention_in_days = local.logs_retention_in_days
}
