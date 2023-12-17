resource "aws_s3_bucket" "profile_image_bucket" {}

resource "aws_s3_bucket" "thumbnail_bucket" {}

resource "aws_s3_bucket_notification" "lambda" {
  bucket = aws_s3_bucket.profile_image_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_image.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket" "log_bucket" {}

resource "aws_s3_bucket_logging" "profile_image" {
  bucket = aws_s3_bucket.profile_image_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/profile-image/"
}

resource "aws_s3_bucket_logging" "thumbnail" {
  bucket = aws_s3_bucket.thumbnail_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/thumbnail/"
}

resource "aws_lambda_permission" "s3_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_image.function_name
  principal     = "s3.amazonaws.com"

  source_arn = "arn:aws:s3:::${aws_s3_bucket.profile_image_bucket.id}"
}