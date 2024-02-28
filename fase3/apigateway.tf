resource "aws_api_gateway_rest_api" "my_api" {
  name = "superaplicacion"
  description = "Superaplicacion(tm) API GW"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  tags = {
    CostCenter = "superaplicacion"
    fase       = "3"
	environment = "PROD"
	}
}

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part = "api"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.root.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = aws_api_gateway_method_response.proxy.status_code

  depends_on = [
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.lambda_integration
  ]
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
#    aws_api_gateway_integration.options_integration, # Add this line
  ]

  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name = "v1"
}


output "deployment_invoke_url" {
  description = "API GW Deployment invoke url"
  value       = "${aws_api_gateway_deployment.deployment.invoke_url}/${aws_api_gateway_resource.root.path_part}"
}

output "apigw_deployment_fqdn" {
  description = "API GW Deployment invoke url"
  value       = replace ( replace( replace( aws_api_gateway_deployment.deployment.invoke_url,"https://","") , aws_api_gateway_deployment.deployment.stage_name, ""), "/", "")
}