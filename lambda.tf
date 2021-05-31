# main
data "archive_file" "main" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/main/"
  output_path = "${path.module}/lambda/main.zip"
}

resource "aws_lambda_function" "main" {
  function_name    = join("-", [local.name, "main"])
  description      = "Lambda manage upload events"
  role             = aws_iam_role.main.arn
  memory_size      = local.memory_size
  runtime          = local.runtime
  timeout          = local.timeout
  handler          = "spleeter-web-service-main.lambda_handler"
  filename         = "${path.module}/lambda/main.zip"
  source_code_hash = data.archive_file.main.output_base64sha256
  tags             = local.tags

  environment {
    variables = {
      STATEMACHINE_ARN = aws_sfn_state_machine.this.arn
    }
  }
}

resource "aws_iam_role" "main" {
  name = join("-", [local.name, "main", "lambda"])

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main_basic_execution" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "main_lambda" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
    ]

    resources = [
      aws_s3_bucket.uploads.arn,
      join("", [aws_s3_bucket.uploads.arn, "/*"])
    ]
  }

  statement {
    actions = [
      "states:Start*"
    ]

    resources = [
      aws_sfn_state_machine.this.arn
    ]
  }
}

resource "aws_iam_role_policy" "main" {
  name   = join("-", [local.name, "main", "lambda"])
  role   = aws_iam_role.main.id
  policy = data.aws_iam_policy_document.main_lambda.json
}

# validate
data "archive_file" "validate" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/validate/"
  output_path = "${path.module}/lambda/validate.zip"
}

resource "aws_lambda_function" "validate" {
  function_name    = join("-", [local.name, "validate"])
  description      = "Lambda manage upload events"
  role             = aws_iam_role.validate.arn
  memory_size      = local.memory_size
  runtime          = local.runtime
  timeout          = local.timeout
  handler          = "spleeter-web-service-validate.lambda_handler"
  filename         = "${path.module}/lambda/validate.zip"
  source_code_hash = data.archive_file.validate.output_base64sha256
  tags             = local.tags
}

resource "aws_iam_role" "validate" {
  name = join("-", [local.name, "validate", "lambda"])

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "validate_basic_execution" {
  role       = aws_iam_role.validate.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "validate_lambda" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
    ]

    resources = [
      aws_s3_bucket.uploads.arn,
      join("", [aws_s3_bucket.uploads.arn, "/*"])
    ]
  }
}

resource "aws_iam_role_policy" "validate" {
  name   = join("-", [local.name, "validate", "lambda"])
  role   = aws_iam_role.validate.id
  policy = data.aws_iam_policy_document.validate_lambda.json
}

# processor
data "archive_file" "processor" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/processor/"
  output_path = "${path.module}/lambda/processor.zip"
}

resource "aws_lambda_function" "processor" {
  function_name    = join("-", [local.name, "processor"])
  description      = "Lambda manage upload events"
  role             = aws_iam_role.processor.arn
  memory_size      = local.memory_size
  runtime          = local.runtime
  timeout          = local.timeout
  handler          = "spleeter-web-service-processor.lambda_handler"
  filename         = "${path.module}/lambda/processor.zip"
  source_code_hash = data.archive_file.processor.output_base64sha256
  tags             = local.tags
}

resource "aws_iam_role" "processor" {
  name = join("-", [local.name, "processor", "lambda"])

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "processor_basic_execution" {
  role       = aws_iam_role.processor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "processor_lambda" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
    ]

    resources = [
      aws_s3_bucket.uploads.arn,
      join("", [aws_s3_bucket.uploads.arn, "/*"])
    ]
  }
}

resource "aws_iam_role_policy" "processor" {
  name   = join("-", [local.name, "processor", "lambda"])
  role   = aws_iam_role.processor.id
  policy = data.aws_iam_policy_document.processor_lambda.json
}