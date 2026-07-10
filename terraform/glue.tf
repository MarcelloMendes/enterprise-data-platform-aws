resource "aws_glue_catalog_database" "enterprise_db" {
  name = "enterprise_data_platform"
}

resource "aws_glue_crawler" "raw_crawler" {
  name          = "crawler-enterprise-data-platform"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.enterprise_db.name

  s3_target {
    path = "s3://${var.bucket_name}/raw/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  depends_on = [
    aws_iam_role_policy_attachment.glue_service,
    aws_iam_role_policy_attachment.glue_s3
  ]
}

resource "aws_glue_job" "etl_job" {
  name     = "etl-process-clientes"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://${var.bucket_name}/scripts/etl_process_clientes.py"
    python_version  = "3"
  }

  glue_version      = "5.0"
  worker_type       = "G.1X"
  number_of_workers = 2

  execution_property {
    max_concurrent_runs = 1
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
  }

  depends_on = [
    aws_glue_catalog_database.enterprise_db
  ]
}