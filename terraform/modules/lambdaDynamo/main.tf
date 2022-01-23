resource "aws_lambda_function" "main" {
  function_name    = var.function_name
  filename         = var.zip_file
  source_code_hash = filebase64sha256(var.zip_file)
  handler          = var.handler
  runtime          = "dotnetcore3.1"
  memory_size      = 256
  timeout          = 30
  role             = aws_iam_role.main.arn

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_iam_role" "main" {
  name = var.function_name

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

resource "aws_iam_role_policy" "dynamodb" {
  name = var.function_name
  role = aws_iam_role.main.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [var.policy]
  })
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = var.logs_retention_in_days
}
