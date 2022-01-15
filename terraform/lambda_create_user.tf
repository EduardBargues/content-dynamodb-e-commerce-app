locals {
  create_customer_file_name = "CreateCustomer.zip"
}
resource "aws_lambda_function" "create_customer" {
  function_name    = "${local.prefix}-create-customer"
  filename         = local.create_customer_file_name
  source_code_hash = filebase64sha256(local.create_customer_file_name)
  handler          = "CreateCustomer::CreateCustomer.Function::Handler"
  runtime          = "dotnetcore3.1"
  memory_size      = 256
  timeout          = 30
  role             = aws_iam_role.create_customer.arn

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.main.name
    }
  }
}

resource "aws_iam_role" "create_customer" {
  name = "${local.prefix}-create-customer"

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

resource "aws_iam_role_policy" "create_customer_dynamodb" {
  name = aws_lambda_function.create_customer.function_name
  role = aws_iam_role.create_customer.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "dynamodb:PutItem"
      ],
      "Resource" : "${aws_dynamodb_table.main.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "create_customer" {
  role       = aws_iam_role.create_customer.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "create_customer" {
  name              = "/aws/lambda/${aws_lambda_function.create_customer.function_name}"
  retention_in_days = local.logs_retention_in_days
}
