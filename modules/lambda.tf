resource "null_resource" "lambda_build" {
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

data "aws_s3_object" "golang_zip" {
  depends_on = [null_resource.lambda_build]

  bucket = aws_s3_bucket.lambda_assets.bucket
  key = local.zip_s3_key
}

data "aws_s3_object" "golang-zip-hash" {
  depends_on = [null_resource.lambda_build]

  bucket = aws_s3_bucket.lambda_assets.bucket
  key = local.zip_base64sha256_s3_key
}

resource "aws_lambda_function" "function_resource_name" {
  function_name = "機能名"
  role = aws_iam_role.lambda_role.arn
  s3_bucket = aws_s3_bucket.lambda_assets.bucket
  s3_key = data.aws_s3_object.golang_zip.key
  handler = "%ハンドラ名%"
  source_code_hash = data.aws_s3_object.golang-zip-hash.body
  runtime  = "go1.x"
  environment {
    variables = {
      aws_region = "ap-northeast-1"
    }
  }
}
