locals {
  PK       = "PK"
  SK       = "SK"
  GSI_1_PK = "GSI_1_PK"
  GSI_1_SK = "GSI_1_SK"
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

  attribute {
    name = local.GSI_1_PK
    type = "S"
  }

  attribute {
    name = local.GSI_1_SK
    type = "S"
  }

  global_secondary_index {
    name               = "GSI_1"
    hash_key           = local.GSI_1_PK
    range_key          = local.GSI_1_SK
    projection_type    = "INCLUDE"
    non_key_attributes = ["OrderId", "ItemId", "Description", "Price", "CreatedAt", "Status", "Amount", "NumberItems"]
  }
}
