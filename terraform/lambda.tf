data "archive_file" "receipt_interpreter_agent" {
  type        = "zip"
  source_file  = "../aws-aai-grocery-man/lambda_functions/receipt_interpreter_agent.py"
  output_path = "../aws-aai-grocery-man/lambda_functions/receipt_interpreter_agent.zip"
}

resource "aws_lambda_function" "receipt_interpreter_agent" {
  function_name = "receipt_interpreter_agent"
  filename      = "../aws-aai-grocery-man/lambda_functions/receipt_interpreter_agent.zip"
  handler       = "receipt_interpreter_agent.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.receipt_interpreter_agent.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.grocery_inventory.name
    }
  }
}

data "archive_file" "expiration_date_estimation_agent" {
  type        = "zip"
  source_file  = "../aws-aai-grocery-man/lambda_functions/expiration_date_estimation_agent.py"
  output_path = "../aws-aai-grocery-man/lambda_functions/expiration_date_estimation_agent.zip"
}

resource "aws_lambda_function" "expiration_date_estimation_agent" {
  function_name = "expiration_date_estimation_agent"
  filename      = "../aws-aai-grocery-man/lambda_functions/expiration_date_estimation_agent.zip"
  handler       = "expiration_date_estimation_agent.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.expiration_date_estimation_agent.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.grocery_inventory.name
    }
  }
}

data "archive_file" "grocery_tracker_agent" {
  type        = "zip"
  source_file  = "../aws-aai-grocery-man/lambda_functions/grocery_tracker_agent.py"
  output_path = "../aws-aai-grocery-man/lambda_functions/grocery_tracker_agent.zip"
}

resource "aws_lambda_function" "grocery_tracker_agent" {
  function_name = "grocery_tracker_agent"
  filename      = "../aws-aai-grocery-man/lambda_functions/grocery_tracker_agent.zip"
  handler       = "grocery_tracker_agent.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.grocery_tracker_agent.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.grocery_inventory.name
    }
  }
}

data "archive_file" "recipe_recommendation_agent" {
  type        = "zip"
  source_file  = "../aws-aai-grocery-man/lambda_functions/recipe_recommendation_agent.py"
  output_path = "../aws-aai-grocery-man/lambda_functions/recipe_recommendation_agent.zip"
}

resource "aws_lambda_function" "recipe_recommendation_agent" {
  function_name = "recipe_recommendation_agent"
  filename      = "../aws-aai-grocery-man/lambda_functions/recipe_recommendation_agent.zip"
  handler       = "recipe_recommendation_agent.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.recipe_recommendation_agent.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.grocery_inventory.name
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid = ""
      },
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_policy"
  description = "IAM policy for Lambda execution"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = [
          "arn:aws:logs:ap-southeast-1:*:*",
          aws_dynamodb_table.grocery_inventory.arn,
          "${aws_dynamodb_table.grocery_inventory.arn}/*"
        ]
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
