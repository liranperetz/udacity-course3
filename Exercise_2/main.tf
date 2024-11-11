provider "aws" {
  access_key = "XXXXX"
  secret_key = "XXXXX"
  region = var.region
}

data "aws_iam_policy_document" "assume_role" {
    statement {
      effect = "Allow"

      principals {
        type = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }

      actions = [ "sts:AssumeRole" ]
    }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda" {
    type = "zip"
    source_file = "greet_lambda.py"
    output_path = "lambda_payload.zip"
}

resource "aws_lambda_function" "greet_lambda" {
  function_name = "greet_lambda"
  role = aws_iam_role.iam_for_lambda.arn
  filename = "lambda_payload.zip"
  handler = "greet_lambda.lambda_handler"

  runtime = "python3.11"

  environment {
    variables = {
      greeting = "Great Job!"
    }
  }
}
