#DATABASE CONFIGURATION

resource "aws_dynamodb_table" "main" {
  name           = "TodosTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
  
  tags = {
    CostCenter = "superaplicacion"
    fase       = "3"
	environment = "PROD"
	}     
  
}
