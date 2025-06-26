# IAM Role para Lambdas
data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${var.project_name}-lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Function 1
resource "aws_lambda_function" "lambda1" {
  function_name    = "${var.project_name}-lambda1"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "main.lambda_handler"
  runtime          = "python3.9"
  filename         = var.lambda1_package
  source_code_hash = filebase64sha256(var.lambda1_package)

  environment {
  }
}

# API Gateway v2 (HTTP)
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"
}

# Integración para Lambda1
resource "aws_apigatewayv2_integration" "lambda1_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.lambda1.arn
}

# Rutas diferenciadas para cada Lambda
resource "aws_apigatewayv2_route" "lambda1_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /lambda1"
  target    = "integrations/${aws_apigatewayv2_integration.lambda1_integration.id}"
}

resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "dev"
  auto_deploy = true
}

# Permisos para invocar las Lambdas desde API Gateway
resource "aws_lambda_permission" "apigw_invoke_lambda1" {
  statement_id  = "AllowAPIGWInvokeLambda1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda1.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
