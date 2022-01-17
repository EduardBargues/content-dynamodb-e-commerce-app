locals {
  update_customer_addresses_file_name = "UpdateCustomerAddresses.zip"
}
resource "aws_lambda_function" "update_customer_addresses" {
  function_name    = "${local.prefix}-update-customer-addresses"
  filename         = local.update_customer_addresses_file_name
  source_code_hash = filebase64sha256(local.update_customer_addresses_file_name)
  handler          = "UpdateCustomerAddresses::UpdateCustomerAddresses.Function::Handler"
  runtime          = "dotnetcore3.1"
  memory_size      = 256
  timeout          = 30
  role             = aws_iam_role.update_customer_addresses.arn

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.main.name
    }
  }
}

resource "aws_iam_role" "update_customer_addresses" {
  name = "${local.prefix}-update-customer-addresses"

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

resource "aws_iam_role_policy" "update_customer_addresses_dynamodb" {
  name = aws_lambda_function.update_customer_addresses.function_name
  role = aws_iam_role.update_customer_addresses.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "dynamodb:UpdateItem"
      ],
      "Resource" : "${aws_dynamodb_table.main.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "update_customer_addresses" {
  role       = aws_iam_role.update_customer_addresses.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "update_customer_addresses" {
  name              = "/aws/lambda/${aws_lambda_function.update_customer_addresses.function_name}"
  retention_in_days = local.logs_retention_in_days
}
