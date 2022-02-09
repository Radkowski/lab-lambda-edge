locals {
  lambda_input = {
    lambda_name = "Lambdaedge-lambda-edge-azure-auth"
  }
}



resource "aws_iam_role" "lambda-role" {
  name = join("", [var.DeploymentName, "-lambda-role"])
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    name = join("", [var.DeploymentName, "-lambda-inline-policy"])

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : ["lambda:ListVersionsByFunction"],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "logs:CreateLogGroup",
          "Resource" : join("", ["arn:aws:logs:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":*"])
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : [
            join("", ["arn:aws:logs:", data.aws_region.current.name, ":", data.aws_caller_identity.current.account_id, ":", "log-group:/aws/lambda/", var.DeploymentName, "-version-detector:*"])
          ]
        }
      ]
    })
  }
}


resource "aws_lambda_function" "version-detector" {
  function_name    = join("", [var.DeploymentName, "-version-detector"])
  role             = aws_iam_role.lambda-role.arn
  handler          = "lambda_function.lambda_handler"
  filename         = "./lambda-version-detector/zip/lambda.zip"
  source_code_hash = filebase64sha256("./lambda-version-detector/zip/lambda.zip")
  runtime          = "python3.8"
  memory_size      = 128
  timeout          = 10
}


data "aws_lambda_invocation" "version-detector" {
  function_name = aws_lambda_function.version-detector.function_name
  input         = jsonencode(local.lambda_input)
}


output "result_entry" {
  value = jsondecode(data.aws_lambda_invocation.version-detector.result)
}
