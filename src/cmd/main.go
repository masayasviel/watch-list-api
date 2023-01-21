package main

import (
	"context"
	"github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
	StatusCode int    `json:"statusCode"`
	Body       string `json:"body"`
}

func HandleRequest(ctx context.Context) (Response, error) {
	return Response{
		StatusCode: 200,
		Body:       "Hello!",
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
