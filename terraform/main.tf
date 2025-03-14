terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.2"
}

provider "aws" {
  region = var.aws_region
}

# Create an S3 bucket to store receipt images and extracted data
resource "aws_s3_bucket" "receipts" {
  bucket = var.bucket_name
}


# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "grocery-management-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid = ""
      }
    ]
  })
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "secretsmanager_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Create a Lambda function
resource "aws_lambda_function" "grocery_management" {
  function_name = "grocery-management-lambda"
  s3_bucket     = aws_s3_bucket.receipts.bucket
  s3_key        = "lambda_functions/python.zip"
  runtime       = "python3.9"
  handler       = "handler.main"
  memory_size   = 128
  timeout       = 30
  role          = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      OPENAI_API_KEY    = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string).OPENAI_API_KEY
      LLAMA_OCR_API_KEY = jsondecode(data.aws_secretsmanager_secret_version.example.secret_string).LLAMA_OCR_API_KEY
    }
  }
}

# Create API Gateway
resource "aws_api_gateway_rest_api" "grocery_api" {
  name        = "grocery-management-api"
  description = "API Gateway for Grocery Management Lambda function"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.grocery_api.id
  parent_id   = aws_api_gateway_rest_api.grocery_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.grocery_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.grocery_api.id
  resource_id             = aws_api_gateway_method.proxy.resource_id
  http_method             = aws_api_gateway_method.proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.grocery_management.invoke_arn
}

resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.grocery_api.id
  stage_name  = "dev"

  depends_on = [
    aws_api_gateway_integration.lambda,
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.grocery_management.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.grocery_api.id}/*/*"
}

data "aws_secretsmanager_secret_version" "example" {
  secret_id = "arn:aws:secretsmanager:us-east-1:203918878138:secret:grocery-management-api-keys-Yv7OQp"
}

data "aws_caller_identity" "current" {}
