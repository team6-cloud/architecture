
/*
aws s3 cp build/ s3://team26-21ah61 --recursive

*/


resource "null_resource" "update_source_files" {
    provisioner "local-exec" {
		command = <<-EOT
			cd src/frontend
			export NODE_OPTIONS="--openssl-legacy-provider --no-deprecation"
			export REACT_APP_API_URL=http://localhost:3001/api
			npm install
			npm run build
			EOT
	    on_failure = fail
    }
}




output "upload_source_files" {
    description 	= 	"upload source files"
	value 			= 	"aws s3 cp build/ s3://${aws_s3_bucket.bucket.id} --recursive"
}