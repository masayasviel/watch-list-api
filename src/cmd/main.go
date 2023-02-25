package main

import (
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
)

type Response struct {
	Id        int    `dynamodbav:"id" json:"id"`
	Title     string `dynamodbav:"title" json:"title"`
	Kana      string `dynamodbav:"kana" json:"kana"`
	ImagePath string `dynamodbav:"imagePath" json:"imagePath"`
}

func HandleRequest(ctx context.Context) (events.APIGatewayProxyResponse, error) {
	sess, err := session.NewSession()
	if err != nil {
		return events.APIGatewayProxyResponse{
			Body:       err.Error(),
			StatusCode: 500,
		}, err
	}
	db := dynamodb.New(sess)
	scanOut, err := db.Scan(&dynamodb.ScanInput{
		TableName: aws.String("animeMaster"),
	})
	if err != nil {
		return events.APIGatewayProxyResponse{
			Body:       err.Error(),
			StatusCode: 500,
		}, err
	}

	var res []Response
	_ = dynamodbattribute.UnmarshalListOfMaps(scanOut.Items, &res)

	jsonBytes, _ := json.Marshal(res)
	return events.APIGatewayProxyResponse{
		Body:       string(jsonBytes),
		StatusCode: 200,
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
