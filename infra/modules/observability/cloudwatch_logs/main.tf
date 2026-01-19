# ------ CLOUDWATCH LOG GROUPS (ECS CONTAINER LOGS) ------

resource "aws_cloudwatch_log_group" "server" {
  name              = "/ecs/${var.name}/server"
  retention_in_days = var.retention_in_days # Controls how long logs are kept (cost + compliance)
}

# ------ SQS QUEUE (ASYNC WORK / LOG EVENTS) ------

resource "aws_cloudwatch_log_group" "consumer" {
  name              = "/ecs/${var.name}/consumer"
  retention_in_days = var.retention_in_days
}
