// This is a simple example of how to develop for AWS Lambda in Go

package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

func HandleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// print the entire request to the log
	fmt.Printf("%+v\n", request)

	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Body:       fmt.Sprintf("Hello %s!", request.Body),
	}, nil
}

func main() {
	lambda.Start(HandleRequest)
}
