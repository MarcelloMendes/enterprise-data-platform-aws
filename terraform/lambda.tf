data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../lambda/lambda_ingestion.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "ingestion_lambda" {
  function_name = "enterprise-data-platform-ingestion"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role    = aws_iam_role.lambda_role.arn
  handler = "lambda_ingestion.lambda_handler"
  runtime = "python3.13"
  timeout = 30

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_s3
  ]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingestion_lambda.function_name
  principal     = "s3.amazonaws.com"

  source_arn = aws_s3_bucket.data_lake.arn
}

resource "aws_s3_bucket_notification" "landing_notification" {
  bucket = aws_s3_bucket.data_lake.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.ingestion_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "landing/"
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}