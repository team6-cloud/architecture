##### Creating an S3 Bucket #####
resource "aws_s3_bucket" "bucket" {
  bucket = "team26-${random_string.random.result}"
  force_destroy = true
  
  tags = {
    CostCenter = "superaplicacion"
    fase       = "3"
	environment = "PROD"
	}     
  
}

resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.iam-policy-1.json
}

data "aws_iam_policy_document" "iam-policy-1" {
  statement {
    sid    = "AllowPublicRead"
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    actions = ["S3:GetObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

output "bucket_name" {
	value = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
  description = "The ARN of the bucket"
}

output "bucket_url" {
    description = "url of the bucket"
	// http://team26-ofl9ma.s3-website-us-east-1.amazonaws.com/
    value       = "http://${aws_s3_bucket.bucket.id}.s3-website-${aws_s3_bucket.bucket.region}.amazonaws.com/"
}