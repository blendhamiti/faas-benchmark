resource "aws_s3_bucket" "lambda_bucket" {}

resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_create_user" {
  type = "zip"

  source_dir  = "${path.module}/functions/createUser"
  output_path = "${path.module}/functions/createUser.zip"
}

data "archive_file" "lambda_process_image" {
  type = "zip"

  source_dir  = "${path.module}/functions/processImage"
  output_path = "${path.module}/functions/processImage.zip"
}

resource "aws_s3_object" "lambda_create_user" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "createUser.zip"
  source = data.archive_file.lambda_create_user.output_path

  etag = filemd5(data.archive_file.lambda_create_user.output_path)
}

resource "aws_s3_object" "lambda_process_image" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "processImage.zip"
  source = data.archive_file.lambda_process_image.output_path

  etag = filemd5(data.archive_file.lambda_process_image.output_path)
}

resource "aws_lambda_function" "create_user" {
  function_name = "CreateUser"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_create_user.key

  runtime     = "nodejs14.x"
  memory_size = 512
  handler     = "createUser.handler"
  environment {
    variables = {
      "PROFILE_IMAGE_BUCKET" = aws_s3_bucket.profile_image_bucket.bucket
      "DB_HOST"              = aws_db_instance.default.address
      "DB_NAME"              = aws_db_instance.default.db_name
      "DB_USER"              = aws_db_instance.default.username
      "DB_PASSWORD"          = aws_db_instance.default.password
    }
  }

  source_code_hash = data.archive_file.lambda_create_user.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_lambda_function" "process_image" {
  function_name = "ProcessImage"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_process_image.key

  runtime     = "nodejs14.x"
  memory_size = 512
  handler     = "processImage.handler"
  environment {
    variables = {
      "THUMBNAIL_BUCKET" = aws_s3_bucket.thumbnail_bucket.bucket
    }
  }

  source_code_hash = data.archive_file.lambda_process_image.output_base64sha256

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "create_user" {
  name = "/aws/lambda/${aws_lambda_function.create_user.function_name}"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "process_image" {
  name = "/aws/lambda/${aws_lambda_function.process_image.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_s3" {
  name = "lambda_s3"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
