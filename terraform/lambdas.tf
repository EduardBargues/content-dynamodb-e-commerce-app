locals {
  lambdas = {
    CreateCustomer = {
      function_name = "${local.prefix}-create-customer"
      handler       = "CreateCustomer::CreateCustomer.Function::Handler"
      policy = {
        Effect   = "Allow",
        Action   = "dynamodb:PutItem",
        Resource = aws_dynamodb_table.main.arn
      }
    }
    CreateOrder = {
      function_name = "${local.prefix}-create-order"
      handler       = "CreateOrder::CreateOrder.Function::Handler"
      policy = {
        Effect   = "Allow",
        Action   = "dynamodb:BatchWriteItem",
        Resource = aws_dynamodb_table.main.arn
      }
    }
    GetCustomerWithRecentOrders = {
      function_name = "${local.prefix}-get-customer-with-recent-orders"
      handler       = "GetCustomerWithRecentOrders::GetCustomerWithRecentOrders.Function::Handler"
      policy = {
        Effect   = "Allow",
        Action   = "dynamodb:Query",
        Resource = aws_dynamodb_table.main.arn
      }
    }
    GetOrder = {
      function_name = "${local.prefix}-get-order"
      handler       = "GetOrder::GetOrder.Function::Handler"
      policy = {
        Effect   = "Allow",
        Action   = "dynamodb:Query",
        Resource = "${aws_dynamodb_table.main.arn}/index/GSI_1"
      }
    }
    UpdateCustomerAddresses = {
      function_name = "${local.prefix}-update-customer-addresses"
      handler       = "UpdateCustomerAddresses::UpdateCustomerAddresses.Function::Handler"
      policy = {
        Effect   = "Allow",
        Action   = "dynamodb:UpdateItem",
        Resource = aws_dynamodb_table.main.arn
      }
    }
  }
}

module "lambdas" {
  source   = "./modules/lambdaDynamo"
  for_each = local.lambdas

  zip_file            = "${each.key}.zip"
  function_name       = each.value.function_name
  handler             = each.value.handler
  dynamodb_table_name = aws_dynamodb_table.main.name
  policy              = each.value.policy
}
