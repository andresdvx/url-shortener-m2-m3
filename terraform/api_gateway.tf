# ===========================
# Referencia al API Gateway HTTP API (v2) existente
# ===========================

# Data source para obtener el HTTP API existente
data "aws_apigatewayv2_api" "existing" {
  api_id = var.api_gateway_id
}

# ===========================
# MÓDULO 2: Integración Lambda - Redirección
# ===========================

# Integración Lambda para redirección (GET /{code})
resource "aws_apigatewayv2_integration" "redirect_integration" {
  api_id                 = data.aws_apigatewayv2_api.existing.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.redirect_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Ruta GET /{code}
resource "aws_apigatewayv2_route" "redirect_route" {
  api_id    = data.aws_apigatewayv2_api.existing.id
  route_key = "GET /{code}"
  target    = "integrations/${aws_apigatewayv2_integration.redirect_integration.id}"
}

# Permiso para que API Gateway invoque Lambda de redirección
resource "aws_lambda_permission" "api_gateway_redirect_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_apigatewayv2_api.existing.execution_arn}/*/*"
}

# ===========================
# MÓDULO 3: Integración Lambda - Estadísticas
# ===========================

# Integración Lambda para estadísticas (GET /stats/{code})
resource "aws_apigatewayv2_integration" "stats_integration" {
  api_id                 = data.aws_apigatewayv2_api.existing.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.stats_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Ruta GET /stats/{code}
resource "aws_apigatewayv2_route" "stats_route" {
  api_id    = data.aws_apigatewayv2_api.existing.id
  route_key = "GET /stats/{code}"
  target    = "integrations/${aws_apigatewayv2_integration.stats_integration.id}"
}

# Permiso para que API Gateway invoque Lambda de estadísticas
resource "aws_lambda_permission" "api_gateway_stats_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stats_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_apigatewayv2_api.existing.execution_arn}/*/*"
}
