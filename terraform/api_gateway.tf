resource "aws_api_gateway_rest_api" "grocery_api" {
  name        = "grocery_api"
  description = "API Gateway for Grocery Management System"
}

resource "aws_api_gateway_resource" "receipt_resource" {
  rest_api_id = aws_api_gateway_rest_api.grocery_api.id
  parent_id   = aws_api_gateway_rest_api.grocery_api.root_resource_id
  path_part   = "receipt"
}

resource "aws_api_gateway_method" "receipt_post" {
  rest_api_id   = aws_api_gateway_rest_api.grocery_api.id
  resource_id   = aws_api_gateway_resource.receipt_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "receipt_lambda_integration" {
  rest_api_id   = aws_api_gateway_rest_api.grocery_api.id
  resource_id   = aws_api_gateway_resource.receipt_resource.id
  http_method   = aws_api_gateway_method.receipt_post.http_method
  integration_http_method = "POST"
  type            = "AWS_PROXY"
  uri             = aws_lambda_function.receipt_interpreter_agent.invoke_arn
}

resource "aws_api_gateway_deployment" "grocery_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.grocery_api.id
  stage_name  = "dev"

  depends_on = [
    aws_api_gateway_integration.receipt_lambda_integration
  ]
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.receipt_interpreter_agent.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.grocery_api.execution_arn}/*/*"
}
