# ===========================
# MÓDULO 2: Lambda de Redirección
# ===========================

# IAM Role para Lambda de Redirección
resource "aws_iam_role" "lambda_redirect_role" {
  name = "url-shortener-redirect-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Module      = "Module2-Redirect"
    Environment = var.environment
  }
}

# Policy para acceso a DynamoDB (Redirección)
resource "aws_iam_role_policy" "lambda_redirect_dynamodb_policy" {
  name = "redirect-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_redirect_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Resource = "arn:aws:dynamodb:${var.aws_region}:*:table/${var.dynamodb_table_name}"
      }
    ]
  })
}

# Attach AWS managed policy para logs
resource "aws_iam_role_policy_attachment" "lambda_redirect_logs" {
  role       = aws_iam_role.lambda_redirect_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Empaquetar código Lambda de Redirección
data "archive_file" "redirect_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../module2-redirect"
  output_path = "${path.module}/lambda_redirect_package.zip"
  excludes    = ["node_modules", ".git"]
}

# Lambda Function de Redirección
resource "aws_lambda_function" "redirect_lambda" {
  filename         = data.archive_file.redirect_lambda_zip.output_path
  function_name    = "url-shortener-redirect"
  role            = aws_iam_role.lambda_redirect_role.arn
  handler         = "src/index.handler"
  source_code_hash = data.archive_file.redirect_lambda_zip.output_base64sha256
  runtime         = "nodejs20.x"
  timeout         = 10
  memory_size     = 256

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  tags = {
    Module      = "Module2-Redirect"
    Environment = var.environment
  }
}

# CloudWatch Log Group para Lambda de Redirección
resource "aws_cloudwatch_log_group" "redirect_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.redirect_lambda.function_name}"
  retention_in_days = 7

  tags = {
    Module      = "Module2-Redirect"
    Environment = var.environment
  }
}

# ===========================
# MÓDULO 3: Lambda de Estadísticas
# ===========================

# IAM Role para Lambda de Estadísticas
resource "aws_iam_role" "lambda_stats_role" {
  name = "url-shortener-stats-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Module      = "Module3-Stats"
    Environment = var.environment
  }
}

# Policy para acceso a DynamoDB (Estadísticas)
resource "aws_iam_role_policy" "lambda_stats_dynamodb_policy" {
  name = "stats-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_stats_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = "arn:aws:dynamodb:${var.aws_region}:*:table/${var.dynamodb_table_name}"
      }
    ]
  })
}

# Attach AWS managed policy para logs
resource "aws_iam_role_policy_attachment" "lambda_stats_logs" {
  role       = aws_iam_role.lambda_stats_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Empaquetar código Lambda de Estadísticas
data "archive_file" "stats_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../module3-stats"
  output_path = "${path.module}/lambda_stats_package.zip"
  excludes    = ["node_modules", ".git"]
}

# Lambda Function de Estadísticas
resource "aws_lambda_function" "stats_lambda" {
  filename         = data.archive_file.stats_lambda_zip.output_path
  function_name    = "url-shortener-stats"
  role            = aws_iam_role.lambda_stats_role.arn
  handler         = "src/index.handler"
  source_code_hash = data.archive_file.stats_lambda_zip.output_base64sha256
  runtime         = "nodejs20.x"
  timeout         = 10
  memory_size     = 256

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  tags = {
    Module      = "Module3-Stats"
    Environment = var.environment
  }
}

# CloudWatch Log Group para Lambda de Estadísticas
resource "aws_cloudwatch_log_group" "stats_lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.stats_lambda.function_name}"
  retention_in_days = 7

  tags = {
    Module      = "Module3-Stats"
    Environment = var.environment
  }
}
