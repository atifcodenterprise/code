# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${lower(var.cluster_prefix)}"
  retention_in_days = 30

  tags = {
    Name = "${lower(var.cluster_prefix)}-cw-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "myapp_log_stream" {
  name           = "${lower(var.cluster_prefix)}-log-stream"
  log_group_name = aws_cloudwatch_log_group.ecs_log_group.name
}
