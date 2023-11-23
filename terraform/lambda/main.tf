provider "aws" {
  region = "eu-west-3" # Paris
}

terraform {
  backend "local" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
