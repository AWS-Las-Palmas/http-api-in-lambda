# Serverless HTTP API on AWS Lambda
AWS Las Palmas User Group Meetup

This repo contains some resources used during the demo at the AWS Las Palmas UG meetup in Las Palmas on November 23, 2023.

# Structure

 * `/api`: Contains minimal code written in Go to provide a generic response to requests
 * `/terraform`: Contains Terraform IAC for ECR, API Gateway, and Lambda
   * `/ecr`: Elastic Container Registry IAC to store the Docker image used during the demo
   * `/lambda`: IAC for API Gateway and Lambda to host the demo API
   * `demo.tfvars`: Terraform variables file containing the instance data specific to the demo
