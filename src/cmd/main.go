package main

import (
	"context"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func HandleRequest(ctx context.Context) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
        Body: "Hello!",
        StatusCode: 200,
        IsBase64Encoded: false,
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
