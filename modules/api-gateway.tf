resource "aws_api_gateway_rest_api" "rest_api_gateway" {
  name        = "Serverless Anime Manage Tool API"
  description = "Terraform Serverless Anime Manage Tool API"
}

resource "aws_api_gateway_resource" "anime_manage" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rest_api_gateway.root_resource_id
  path_part   = "anime-manage"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api_gateway.id
  resource_id   = aws_api_gateway_resource.anime_manage.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.function_resource_name.invoke_arn
}

resource "aws_api_gateway_deployment" "api_gateway_deploy" {
  depends_on = [
    aws_api_gateway_integration.lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.rest_api_gateway.id
  stage_name  = "anime-manage-tool-api-stage"

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api_gateway.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}