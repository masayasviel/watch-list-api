data "aws_caller_identity" "current" {}

resource "aws_iam_role" "lambda_role" {
  name = "anime-manage-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_caller_identity.current.arn}",
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda2dynamodb-policy" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Get*",
        "dynamodb:List*",
        "dynamodb:Query",
        "dynamodb:Scan",
        "dynamodb:Update*",
        "dynamodb:PutItem"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.anime-master-table.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_for_attachment" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda2dynamodb-policy.arn
}
