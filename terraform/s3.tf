resource "aws_s3_bucket" "data_lake" {
  bucket = var.bucket_name

  tags = {
    Name = "Enterprise Data Platform Data Lake"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.data_lake.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "landing_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "landing/"
}

resource "aws_s3_object" "raw_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "raw/"
}

resource "aws_s3_object" "processed_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "processed/"
}

resource "aws_s3_object" "athena_results_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "athena-results/"
}