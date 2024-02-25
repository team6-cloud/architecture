# Provider
provider "aws" {
  region = "us-east-1"
}
# Variables
variable "labrole_arn" {
	type = string
	default = "arn:aws:iam::851725203079:role/LabRole"
}
variable "aws_access_key_id" {
  description = "AWS access key"
  type        = string
  default     = "ASIA4MTWHG2DVCNR33AI"
}
variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  default     = "zjhEc37/gl/UsM1a0RHUhsXruBexSGXLP88uq9lW"
}
variable "aws_session_token" {
  description = "AWS session token"
  type        = string
  default     = "FwoGZXIvYXdzEM7//////////wEaDMRkv56Fzjop3YX2JCK8AV3QyAp814TFtvh65wLG592McYvymysmAWKLWzbVXlKkbpzs+XsbkTuZSh5+DfYER1rPxqjuHKQJTm7xkxNByoVX43rih3PTwLek7JPtPdcAgVYGkY5nSvYAcTy2LDQ9VMEe9R6pnmnnjCTBxzV6Z7kpHZpq7cH01LKnC+WECaAuRZesex/cmaaFCE0iN9Koos8vfieCfl8K5krudxggsS7L/hT+yQc4ijhPmlvPnA7MqSd7njXkQtgnPkljKJHp7K4GMi131pJEgxvrzv4Bv1xt8m3985AZorsAGYfMIcT9W4GCbfiB1LH96OGRNBLAYEw="
}
# DynamoDB Table
resource "aws_dynamodb_table" "todos_table" {
  name           = "TodosTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
#Lambda Layer
data "archive_file" "test_lambda_layer" {
  type        = "zip"
  source_dir  = "./lambda/layers/commonLibs"
  output_path = "./lambda/commonLibs.zip"
}
resource "aws_lambda_layer_version" "test_lambda_layer" {
  layer_name       = "test_lambda_layer"
  description      = "A layer for Node.js"
  filename         = data.archive_file.test_lambda_layer.output_path
  source_code_hash = data.archive_file.test_lambda_layer.output_base64sha256
  compatible_runtimes = ["nodejs16.x", "nodejs18.x", "nodejs20.x"]
}
# Lambda Functions
data "archive_file" "getTodos" {
  type        = "zip"
  source_dir  = "./lambda/getTodos"
  output_path = "./lambda/getTodos.zip"
}
data "archive_file" "getTodosById" {
  type        = "zip"
  source_dir  = "./lambda/getTodosById"
  output_path = "./lambda/getTodosById.zip"
}
data "archive_file" "createTodo" {
  type        = "zip"
  source_dir  = "./lambda/createTodo"
  output_path = "./lambda/createTodo.zip"
}
data "archive_file" "updateTodo" {
  type        = "zip"
  source_dir  = "./lambda/updateTodo"
  output_path = "./lambda/updateTodo.zip"
}
data "archive_file" "deleteTodo" {
  type        = "zip"
  source_dir  = "./lambda/deleteTodo"
  output_path = "./lambda/deleteTodo.zip"
}
resource "aws_lambda_function" "getTodos" {
  function_name    = "getTodos"
  runtime          = "nodejs20.x"
  handler          = "index.handler"

  filename         = data.archive_file.getTodos.output_path
  source_code_hash = data.archive_file.getTodos.output_base64sha256
  memory_size   = 256 
  role             = var.labrole_arn

  layers = [aws_lambda_layer_version.test_lambda_layer.arn] #Will use the layer created in the previous step 

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.todos_table.name
      ASDF_KEY_ID     = var.aws_access_key_id
      ASDF_SECRET_KEY = var.aws_secret_access_key
      ASDF_SECRET_TOKEN      = var.aws_session_token
    }
  }
}
resource "aws_lambda_function" "getTodosById" {
  function_name    = "getTodosById"
  runtime          = "nodejs20.x"
  handler          = "index.handler"

  filename         = data.archive_file.getTodosById.output_path
  source_code_hash = data.archive_file.getTodosById.output_base64sha256
  memory_size   = 256 
  role             = var.labrole_arn

  layers = [aws_lambda_layer_version.test_lambda_layer.arn] #Will use the layer created in the previous step 

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.todos_table.name
      ASDF_KEY_ID     = var.aws_access_key_id
      ASDF_SECRET_KEY = var.aws_secret_access_key
      ASDF_SECRET_TOKEN      = var.aws_session_token
    }
  }
}
resource "aws_lambda_function" "createTodo" {
  function_name    = "createTodo"
  runtime          = "nodejs20.x"
  handler          = "index.handler"

  filename         = data.archive_file.createTodo.output_path
  source_code_hash = data.archive_file.createTodo.output_base64sha256
  memory_size   = 256 
  role             = var.labrole_arn

  layers = [aws_lambda_layer_version.test_lambda_layer.arn] #Will use the layer created in the previous step 

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.todos_table.name
      ASDF_KEY_ID     = var.aws_access_key_id
      ASDF_SECRET_KEY = var.aws_secret_access_key
      ASDF_SECRET_TOKEN      = var.aws_session_token
    }
  }
}
resource "aws_lambda_function" "updateTodo" {
  function_name    = "updateTodo"
  runtime          = "nodejs20.x"
  handler          = "index.handler"

  filename         = data.archive_file.updateTodo.output_path
  source_code_hash = data.archive_file.updateTodo.output_base64sha256
  memory_size   = 256 
  role             = var.labrole_arn

  layers = [aws_lambda_layer_version.test_lambda_layer.arn] #Will use the layer created in the previous step 

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.todos_table.name
      ASDF_KEY_ID     = var.aws_access_key_id
      ASDF_SECRET_KEY = var.aws_secret_access_key
      ASDF_SECRET_TOKEN      = var.aws_session_token
    }
  }
}
resource "aws_lambda_function" "deleteTodo" {
  function_name    = "deleteTodo"
  runtime          = "nodejs20.x"
  handler          = "index.handler"

  filename         = data.archive_file.deleteTodo.output_path
  source_code_hash = data.archive_file.deleteTodo.output_base64sha256
  memory_size   = 256 
  role             = var.labrole_arn

  layers = [aws_lambda_layer_version.test_lambda_layer.arn] #Will use the layer created in the previous step 

  environment {
    variables = {
      TABLE_NAME     = aws_dynamodb_table.todos_table.name
      ASDF_KEY_ID     = var.aws_access_key_id
      ASDF_SECRET_KEY = var.aws_secret_access_key
      ASDF_SECRET_TOKEN      = var.aws_session_token
    }
  }
}
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getTodos.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*/todos"
}
resource "aws_lambda_permission" "apigw2" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getTodosById.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*/todos/{id}"
}
resource "aws_lambda_permission" "apigw3" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.createTodo.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*/todos"
}
resource "aws_lambda_permission" "apigw4" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.updateTodo.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*/todos/{id}"
}
resource "aws_lambda_permission" "apigw5" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.deleteTodo.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*/todos/{id}"
}
# API Gateway
# Create a REST API
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "MyAPI"
}
# Create a Resource
resource "aws_api_gateway_resource" "todos" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "todos"
}
resource "aws_api_gateway_resource" "todo_by_id" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_resource.todos.id
  path_part   = "{id}" # This specifies a path parameter named 'id'
}
# Create Methods
resource "aws_api_gateway_method" "get_todos" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "GET"
  authorization = "NONE"
  depends_on    = [aws_api_gateway_rest_api.my_api]
}
# Method for GET /todos/:id
resource "aws_api_gateway_method" "get_todos_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todo_by_id.id
  http_method   = "GET"
  authorization = "NONE"
  depends_on    = [aws_api_gateway_rest_api.my_api]
}
resource "aws_api_gateway_method" "create_todo" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "POST"
  authorization = "NONE"
  depends_on    = [aws_api_gateway_rest_api.my_api]
}
resource "aws_api_gateway_method" "update_todo" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todo_by_id.id
  http_method   = "PUT"
  authorization = "NONE"
  depends_on    = [aws_api_gateway_rest_api.my_api]
}
resource "aws_api_gateway_method" "delete_todo" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.todo_by_id.id
  http_method   = "DELETE"
  authorization = "NONE"
  depends_on    = [aws_api_gateway_rest_api.my_api]
}
# Create Integrations
resource "aws_api_gateway_integration" "lambda_get_todos" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.get_todos.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getTodos.invoke_arn
}
# Integration for GET /todos/:id
resource "aws_api_gateway_integration" "lambda_get_todos_by_id" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todo_by_id.id
  http_method = aws_api_gateway_method.get_todos_by_id.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getTodosById.invoke_arn
}
resource "aws_api_gateway_integration" "lambda_create_todo" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.create_todo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.createTodo.invoke_arn
}
resource "aws_api_gateway_integration" "lambda_update_todo" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todo_by_id.id
  http_method = aws_api_gateway_method.update_todo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.updateTodo.invoke_arn
}
resource "aws_api_gateway_integration" "lambda_delete_todo" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.todo_by_id.id
  http_method = aws_api_gateway_method.delete_todo.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.deleteTodo.invoke_arn
}
# Create a Method Response
resource "aws_api_gateway_deployment" "my_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_get_todos, 
    aws_api_gateway_integration.lambda_get_todos_by_id, 
    aws_api_gateway_integration.lambda_create_todo, 
    aws_api_gateway_integration.lambda_update_todo, 
    aws_api_gateway_integration.lambda_delete_todo
    ]
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "prod"
}
# Outputs
output "api_endpoint" {
  value = aws_api_gateway_deployment.my_deployment.invoke_url
}
# S3 Bucket
resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}
resource "aws_s3_bucket" "react_app" {
    bucket = "react-app-${random_string.bucket_suffix.result}"
    force_destroy = true
}
resource "aws_s3_bucket_website_configuration" "react" {
  bucket = aws_s3_bucket.react_app.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}
resource "aws_s3_bucket_public_access_block" "react" {
  bucket = aws_s3_bucket.react_app.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_object" "upload_object" {
  for_each      = fileset("html/", "*")
  bucket        = aws_s3_bucket.react_app.id
  key           = each.value
  source        = "html/${each.value}"
  etag          = filemd5("html/${each.value}")
  content_type  = "text/html"
}
# CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.react_app.bucket_regional_domain_name
    origin_id   = "S3-myReactApp"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.s3_oai.id}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-myReactApp"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "OAI for React App"
}

output "lambda_function_arn" {
  value = aws_lambda_function.getTodos.arn
}
output "dynamodb_table_name" {
  value = aws_dynamodb_table.todos_table.name
}
output "s3_bucket_name" {
  value = aws_s3_bucket.react_app.bucket
}
output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}
output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}
