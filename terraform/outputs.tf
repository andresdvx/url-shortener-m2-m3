output "lambda_redirect_function_name" {
  description = "Nombre de la función Lambda de redirección"
  value       = aws_lambda_function.redirect_lambda.function_name
}

output "lambda_redirect_arn" {
  description = "ARN de la función Lambda de redirección"
  value       = aws_lambda_function.redirect_lambda.arn
}

output "lambda_stats_function_name" {
  description = "Nombre de la función Lambda de estadísticas"
  value       = aws_lambda_function.stats_lambda.function_name
}

output "lambda_stats_arn" {
  description = "ARN de la función Lambda de estadísticas"
  value       = aws_lambda_function.stats_lambda.arn
}

output "api_gateway_url" {
  description = "URL base del API Gateway"
  value       = "https://${var.api_gateway_id}.execute-api.${var.aws_region}.amazonaws.com"
}

output "redirect_endpoint" {
  description = "Endpoint de redirección"
  value       = "https://${var.api_gateway_id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/{code}"
}

output "stats_endpoint" {
  description = "Endpoint de estadísticas"
  value       = "https://${var.api_gateway_id}.execute-api.${var.aws_region}.amazonaws.com/${var.environment}/stats/{code}"
}
