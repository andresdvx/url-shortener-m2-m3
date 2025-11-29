variable "aws_region" {
  description = "AWS region donde se desplegarán los recursos"
  type        = string
  default     = "us-west-1"
}

variable "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB existente"
  type        = string
  default     = "url_shortener"
}

variable "api_gateway_id" {
  description = "ID del HTTP API Gateway existente (v2)"
  type        = string
  default     = "v6d8eib0zb"
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  default     = "dev"
}

variable "aws_access_key" {
  description = "AWS Access Key ID para autenticación"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key para autenticación"
  type        = string
  sensitive   = true
  default     = ""
}
