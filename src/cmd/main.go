package main

import (
	"context"
	"encoding/json"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
)

func HandleRequest(ctx context.Context) (events.APIGatewayProxyResponse, error) {
	sess, err := session.NewSession()
	if err != nil {
		return events.APIGatewayProxyResponse{
			Body:       err.Error(),
			StatusCode: 500,
		}, err
	}
	db := dynamodb.New(sess)
	out, err := db.Scan(&dynamodb.ScanInput{
		TableName: aws.String("animeMaster"),
	})
	if err != nil {
		return events.APIGatewayProxyResponse{
			Body:       err.Error(),
			StatusCode: 500,
		}, err
	}
	jsonBytes, _ := json.Marshal(out)
	return events.APIGatewayProxyResponse{
		Body:            string(jsonBytes),
		StatusCode:      200,
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
