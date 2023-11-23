# Log group for storing logs from Lambda
resource "aws_cloudwatch_log_group" "api_lambda" {
  name = "/aws/lambda/${var.name}-api"
}

# Default IAM role for Lambda
resource "aws_iam_role" "api_lambda" {
  name = "${var.name}-api"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
          "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# IAM policy to allow Lambda to push logs to logging service
resource "aws_iam_policy" "api_lambda_logging" {
  name        = "${var.name}-api-lambda-logging"
  description = "IAM policy to allow ${var.name}-api Lambda to push logs to logging service"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.api_lambda.arn}:*"
      ]
    }
  ]
}
EOF
}

# Assign the log-push policy to the default Lambda role
resource "aws_iam_role_policy_attachment" "backend_lambda_logs" {
  role       = aws_iam_role.api_lambda.name
  policy_arn = aws_iam_policy.api_lambda_logging.arn
}

# The Lambda function
resource "aws_lambda_function" "api" {
  function_name = "${var.name}-api"
  role          = aws_iam_role.api_lambda.arn
  package_type  = "Image"
  image_uri     = var.default_image
  memory_size   = 128
  timeout       = 10

  depends_on = [
    aws_iam_role_policy_attachment.backend_lambda_logs,
    aws_cloudwatch_log_group.api_lambda,
  ]
}

# API gateway
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.name}-api"
  description = "Api gateway for ${var.name}-api Lambda"
}

# Specify API gateway proxy mode
resource "aws_api_gateway_resource" "api_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

# Specify which methods should be served
resource "aws_api_gateway_method" "api_any" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

# Assign API gateway settings
resource "aws_api_gateway_integration" "api" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api_proxy.id
  http_method             = aws_api_gateway_method.api_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

# Lambda permission to allow the API gateway to invoke it
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.api_any.http_method}/*"
}

# API gateway deployment stage
resource "aws_api_gateway_deployment" "live" {
  depends_on = [
    aws_api_gateway_integration.api
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "live"
}
