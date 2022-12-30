resource "aws_iam_role" "lambda_role" {
  name = "anime-manage-lambda-role"

  assume_role_policy = file("${path.module}/policies/aws_assume_role_policy.json")
}

data "aws_iam_policy" "lambda2dynamodb-policy" {
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
  for_each = toset(
    flatten([
      [data.aws_iam_policy.lambda2dynamodb-policy.arn]
    ])
  )
  policy_arn = each.key
}