terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Set the AWS credentials profile and region you want to publish to.
provider "aws" {
  profile = var.aws_credentials_profile
  region  = var.region
}

# --- AppSync Setup ---

# Create the AppSync GraphQL api.
resource "aws_appsync_graphql_api" "appsync" {
  name                = "${var.prefix}_appsync"
  schema              = file("schema.graphql")
  authentication_type = "API_KEY"
}

# Create the API key.
resource "aws_appsync_api_key" "appsync_api_key" {
  api_id = aws_appsync_graphql_api.appsync.id
}

# --- listPeople ---

# Create zip file from Go list-people binary.
data "archive_file" "listPeople_lambda_zip" {
  type        = "zip"
  source_file = "./bin/list-people"
  output_path = "./zip/list-people.zip"
}

# Create lambda function from zip file, with lambda role.
resource "aws_lambda_function" "listPeople_lambda" {
  function_name    = "${var.prefix}_listPeople_lambda"
  filename         = data.archive_file.listPeople_lambda_zip.output_path
  source_code_hash = data.archive_file.listPeople_lambda_zip.output_base64sha256
  role             = aws_iam_role.iam_lambda_role.arn
  runtime          = "go1.x"
  handler          = "list-people"
}

# Create data source in appsync from lambda function.
resource "aws_appsync_datasource" "listPeople_datasource" {
  name             = "${var.prefix}_listPeople_datasource"
  api_id           = aws_appsync_graphql_api.appsync.id
  service_role_arn = aws_iam_role.iam_appsync_role.arn
  type             = "AWS_LAMBDA"
  lambda_config {
    function_arn = aws_lambda_function.listPeople_lambda.arn
  }
}

# Create resolver using the velocity templates in /resolvers/lambda.
resource "aws_appsync_resolver" "listPeople_resolver" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "listPeople"
  data_source = aws_appsync_datasource.listPeople_datasource.name

  request_template  = file("./resolvers/lambda/request.vtl")
  response_template = file("./resolvers/lambda/response.vtl")
}
