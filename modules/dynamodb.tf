resource "aws_dynamodb_table" "anime-master-table" {
  name = "animeMaster"
  hash_key = "id"
  range_key = "kana"

  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "title"
    type = "S"
  }

  attribute {
    name = "kana"
    type = "S"
  }

  attribute {
    name = "imagePath"
    type = "S"
  }
}
