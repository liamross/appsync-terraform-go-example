# This should be whatever AWS credentials profile you want to use to publish
# your AppSync service.
variable "aws_credentials_profile" {
  default = "default"
}

# This is the region the service will be built in. Set this to a valid AWS
# region.
variable "region" {
  default = "us-west-2"
}

# This is the prefix for the name of every created service. This can be anything
# you want, it is solely to prevent naming clashes if multiple AppSync services
# are published.
variable "prefix" {
  default = "appsync_terraform_go_example"
}
