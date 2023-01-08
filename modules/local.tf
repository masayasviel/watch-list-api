locals {
  codedir_local_path = "${path.module}/../src/cmd"
  binary_local_path = "${path.module}/../src/bin/main"
  zip_local_path = "${path.module}/../src/archive/main.zip"
  zip_s3_key = "archive/main.zip"
  zip_base64sha256_local_path = "${local.zip_local_path}.base64sha256"
  zip_base64sha256_s3_key = "encoded/tmp.base64sha256"
}
