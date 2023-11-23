data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

variable "name" {
  description = "Name of the application used as a prefix in resource names"
  type        = string
}

variable "default_image" {
  description = "Default docker image hosted on ECR for Lambda to use when created"
  type        = string
}
