resource "aws_athena_workgroup" "primary" {
  name = "enterprise-data-platform"

  configuration {
    enforce_workgroup_configuration = true

    result_configuration {
      output_location = "s3://${var.bucket_name}/athena-results/"
    }
  }

  state = "ENABLED"
}