// https://github.com/aws-samples/serverless-patterns/blob/main/eventbridge-lambda-terraform/main.tf


resource "aws_lambda_function" "lambda_function" {
  function_name    = "Lambda_Backend"
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "app.handler"
  role             = data.aws_iam_role.labrole.arn
  runtime          = "nodejs20.x"               // FIXME
}

data "archive_file" "lambda_zip_file" {
  type        = "zip"
  source_file = "${path.module}/src/index.mjs"
  output_path = "${path.module}/lambda.zip"
}

output "Lambda_Backend" {
  value       = aws_lambda_function.lambda_function.arn
  description = "back-end function name"
}