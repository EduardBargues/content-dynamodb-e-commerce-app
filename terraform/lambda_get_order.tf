locals {
  get_order_file_name = "GetOrder.zip"
}
resource "aws_lambda_function" "get_order" {
  function_name    = "${local.prefix}-get-order"
  filename         = local.get_order_file_name
  source_code_hash = filebase64sha256(local.get_order_file_name)
  handler          = "GetOrder::GetOrder.Function::Handler"
  runtime          = "dotnetcore3.1"
  memory_size      = 256
  timeout          = 30
  role             = aws_iam_role.get_order.arn

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.main.name
    }
  }
}

resource "aws_iam_role" "get_order" {
  name = "${local.prefix}-get-order"

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

resource "aws_iam_role_policy" "get_order_dynamodb" {
  name = aws_lambda_function.get_order.function_name
  role = aws_iam_role.get_order.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : [
        "dynamodb:Query"
      ],
      "Resource" : "${aws_dynamodb_table.main.arn}/index/GSI_1"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "get_order" {
  role       = aws_iam_role.get_order.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "get_order" {
  name              = "/aws/lambda/${aws_lambda_function.get_order.function_name}"
  retention_in_days = local.logs_retention_in_days
}
