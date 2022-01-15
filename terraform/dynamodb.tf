locals {
  PK = "PK"
  SK = "SK"
}
resource "aws_dynamodb_table" "main" {
  name         = local.prefix
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = local.PK
  range_key    = local.SK

  attribute {
    name = local.PK
    type = "S"
  }

  attribute {
    name = local.SK
    type = "S"
  }
}
