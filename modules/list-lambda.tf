locals {
  codedir_local_path = "${path.module}/../src/cmd/list"
  binary_local_path = "${path.module}/../src/bin/list"
  zip_local_path = "${path.module}/../src/archive/list.zip"
  zip_s3_key = "archive/list.zip"
  zip_base64sha256_local_path = "${local.zip_local_path}.base64sha256"
  zip_base64sha256_s3_key = "encoded/list.base64sha256"
}

resource "null_resource" "lambda_build_for_list" {
  depends_on = [aws_s3_bucket.lambda_assets]

  triggers = {
    code_diff = join("", [
      for file in fileset(local.codedir_local_path, "*.go")
      : filebase64("${local.codedir_local_path}/${file}")
    ])
  }

  provisioner "local-exec" {
    command = "GOARCH=amd64 GOOS=linux go build -o ${local.binary_local_path} ${local.codedir_local_path}/*.go"
  }
  provisioner "local-exec" {
    command = "zip -j ${local.zip_local_path} ${local.binary_local_path}"
  }
  provisioner "local-exec" {
    command = "aws s3 cp ${local.zip_local_path} s3://${aws_s3_bucket.lambda_assets.bucket}/${local.zip_s3_key}"
  }
  provisioner "local-exec" {
    command = "openssl dgst -sha256 -binary ${local.zip_local_path} | openssl enc -base64 | tr -d \"\n\" > ${local.zip_base64sha256_local_path}"
  }
  provisioner "local-exec" {
    command = "aws s3 cp ${local.zip_base64sha256_local_path} s3://${aws_s3_bucket.lambda_assets.bucket}/${local.zip_base64sha256_s3_key} --content-type \"text/plain\""
  }
}

data "aws_s3_object" "golang_zip_for_list" {
  depends_on = [null_resource.lambda_build_for_list]

  bucket = aws_s3_bucket.lambda_assets.bucket
  key = local.zip_s3_key
}

data "aws_s3_object" "golang-zip-hash-for-list" {
  depends_on = [null_resource.lambda_build_for_list]

  bucket = aws_s3_bucket.lambda_assets.bucket
  key = local.zip_base64sha256_s3_key
}

resource "aws_lambda_function" "function_resource_name_for_list" {
  function_name = "main"
  role = aws_iam_role.lambda_role.arn
  s3_bucket = aws_s3_bucket.lambda_assets.bucket
  s3_key = data.aws_s3_object.golang_zip_for_list.key
  handler = "main"
  source_code_hash = data.aws_s3_object.golang-zip-hash-for-list.body
  runtime  = "go1.x"
  environment {
    variables = {
      aws_region = "ap-northeast-1"
    }
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function_resource_name_for_list.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.rest_api_gateway.execution_arn}/*/*"
}
