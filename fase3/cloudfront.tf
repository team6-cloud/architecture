locals {
//  s3_origin_id   = "${var.s3_name}-origin"
//  s3_domain_name = "${var.s3_name}.s3-website-us-west-2.amazonaws.com"
  s3_origin_id   = "${aws_s3_bucket.bucket.id}-origin"
//  s3_domain_name = "${aws_s3_bucket.bucket.id}.s3-website-us-west-2.amazonaws.com"
  s3_domain_name = "${aws_s3_bucket.bucket.id}.s3-website-${aws_s3_bucket.bucket.region}.amazonaws.com"
}

resource "aws_cloudfront_distribution" "main_distribution" {
  
  enabled = true
  
  origin {	// S3
    origin_id                = local.s3_origin_id
    domain_name              = local.s3_domain_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  
  origin { // API GW
//    domain_name = aws_api_gateway_deployment.deployment.invoke_url
    domain_name = replace ( replace( replace( aws_api_gateway_deployment.deployment.invoke_url,"https://","") , aws_api_gateway_deployment.deployment.stage_name, ""), "/", "")
    origin_id   = aws_api_gateway_rest_api.my_api.id
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  

  default_cache_behavior {
    
    target_origin_id = local.s3_origin_id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
  
 ordered_cache_behavior {
    viewer_protocol_policy = "redirect-to-https" 
    allowed_methods = ["HEAD", "OPTIONS", "GET", "PUT", "POST", "DELETE", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    path_pattern     = "/${aws_api_gateway_deployment.deployment.stage_name}/${aws_api_gateway_resource.root.path_part}/*"
    target_origin_id = aws_api_gateway_rest_api.my_api.id

    forwarded_values {
      query_string = true
      cookies { 
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_200"
  
  
  tags = {
    CostCenter = "superaplicacion"
    fase       = "3"
	environment = "PROD"
	}  
}

output "cloudfront_url" {
  description = "Cloudfront domain name"
  value       = aws_cloudfront_distribution.main_distribution.domain_name
}

output "cloudfront_fqdn" {
  description = "cloudfront FQDN"
  value = replace(aws_cloudfront_distribution.main_distribution.domain_name, "https://", "")
}