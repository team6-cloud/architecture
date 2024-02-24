// https://github.com/aws-samples/serverless-patterns/blob/main/eventbridge-lambda-terraform/main.tf


resource "aws_lambda_function" "lambda_function" {
  function_name    = "backend"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "app.handler"
//  role             = aws_iam_role.labrole.arn
  role             = data.aws_iam_role.labrole.arn
  runtime          = "nodejs16.x"               // FIXME
}

data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_file = "${path.module}/src/backend.js"
  output_path = "${path.module}/lambda.zip"
}

output "Lambda_Backend" {
  value       = aws_lambda_function.lambda_function.arn
  description = "back-end function name"
}