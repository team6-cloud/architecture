
/*
aws s3 cp build/ s3://team26-21ah61 --recursive

*/


resource "null_resource" "update_source_files" {
    provisioner "local-exec" {
		command = <<-EOT
			cd src/frontend
			export NODE_OPTIONS="--openssl-legacy-provider --no-deprecation"
			#export REACT_APP_API_URL=https://localhost:3001/api
            export REACT_APP_API_URL=https://${aws_cloudfront_distribution.main_distribution.domain_name}/${aws_api_gateway_deployment.deployment.stage_name}/${aws_api_gateway_resource.root.path_part}
			npm install
			npm run build
			aws s3 cp build/ s3://${aws_s3_bucket.bucket.id} --recursive
			EOT
	    on_failure = fail
    }
	
	depends_on = [aws_s3_bucket.bucket, aws_cloudfront_distribution.main_distribution]
	
}




output "upload_source_files" {
    description 	= 	"upload source files"
	value 			= 	"aws s3 cp src/frontend/build/ s3://${aws_s3_bucket.bucket.id} --recursive"
}