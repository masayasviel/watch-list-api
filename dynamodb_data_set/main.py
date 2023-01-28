import boto3

def main():
    dynamo = boto3.resource('dynamodb')
    dynamo_table = dynamo.Table('animeMaster')
    dynamo_table.put_item(Item=dict(
        id=1,
        title="けいおん",
        kana="ケイオン",
        imagePath="/path/to/s3"
    ))

if __name__ == "__main__":
    main()
