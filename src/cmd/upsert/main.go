package main

import (
	"context"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"log"
)

type Item struct {
	Id        int    `dynamodbav:"id"`
	Title     string `dynamodbav:"title"`
	Kana      string `dynamodbav:"kana"`
	ImagePath string `dynamodbav:"imagePath"`
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
	item := Item{
		Id:        0,
		Title:     "title",
		Kana:      "kana",
		ImagePath: "path/to/img",
	}

	av, err := dynamodbattribute.MarshalMap(item)
	if err != nil {
		log.Fatalf("Got error marshalling new movie item: %s", err)
	}
	_, err = db.PutItem(&dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String("animeMaster"),
	})
	if err != nil {
		return events.APIGatewayProxyResponse{
			Body:       err.Error(),
			StatusCode: 500,
		}, err
	}

	return events.APIGatewayProxyResponse{
		StatusCode: 201,
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
