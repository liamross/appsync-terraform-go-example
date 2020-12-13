package main

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

// Person is a structure describing a person.
type Person struct {
	ID   string `json:"id"`
	Name string `json:"name"`
}

// Handler returns a list of Person.
func Handler(ctx context.Context, event events.AppSyncResolverTemplate) ([]Person, error) {
	return []Person{
		{ID: "person_1", Name: "John Doe"},
		{ID: "person_2", Name: "Jane Doe"},
	}, nil
}

func main() {
	lambda.Start(Handler)
}
