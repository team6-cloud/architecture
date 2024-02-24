data "archive_file" "lambda_package" {
  type = "zip"
  source_file = "lambda/index.js"
  output_path = "lambda/index.zip"
}



data "aws_iam_role" "labrole" {
  name = "LabRole"
}

/*
data "" {

	type = string
	 = "arn:aws:iam::851725525762:role/LabRole"

}
*/