resource "aws_dynamodb_table" "grocery_inventory" {
  name           = "grocery_inventory"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "item_name"

  attribute {
    name = "item_name"
    type = "S"
  }
}
