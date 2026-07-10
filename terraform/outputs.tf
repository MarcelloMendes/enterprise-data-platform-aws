output "bucket_name" {
  value = aws_s3_bucket.data_lake.bucket
}

output "lambda_name" {
  value = aws_lambda_function.ingestion_lambda.function_name
}

output "glue_database" {
  value = aws_glue_catalog_database.enterprise_db.name
}

output "crawler_name" {
  value = aws_glue_crawler.raw_crawler.name
}

output "glue_job" {
  value = aws_glue_job.etl_job.name
}

output "athena_workgroup" {
  value = aws_athena_workgroup.primary.name
}