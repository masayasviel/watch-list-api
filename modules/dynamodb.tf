resource "aws_dynamodb_table" "anime-master-table" {
  name = "animeMaster"
  hash_key = "id"
  range_key = "kana"
  read_capacity = 1
  write_capacity = 1

  attribute {
    name = "id"
    type = "N"
  }

  attribute {
    name = "kana"
    type = "S"
  }
}
