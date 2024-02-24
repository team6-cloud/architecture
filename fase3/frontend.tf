
/*
aws s3 cp build/ s3://team26-21ah61 --recursive

*/


resource "null_resource" "update_source_files" {
    provisioner "local-exec" {
//        command     = "git clone https://github.com/team6-cloud/docker-frontend.git -b develop; " 
		command = <<-EOT
            rm -rf docker-frontend || true
			git clone https://github.com/team6-cloud/docker-frontend.git -b develop
			cd docker-frontend
			export NODE_OPTIONS="--openssl-legacy-provider --no-deprecation"
			export REACT_APP_API_URL=http://localhost:3001/api
			npm install
			npm run build
			EOT
	    on_failure = fail
    }
}