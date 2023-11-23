# ECR repository for storing Docker images for Lambda
resource "aws_ecr_repository" "api_ecr" {
  name = "${var.name}-api"
}

# Policy to allow Lambda to pull images from ECR
resource "aws_ecr_repository_policy" "api_ecr" {
  repository = aws_ecr_repository.api_ecr.name

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "LambdaECRImageRetrievalPolicy",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": [
        "ecr:BatchGetImage",
        "ecr:DeleteRepositoryPolicy",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:SetRepositoryPolicy"
      ]
    }
  ]
}
EOF
}
