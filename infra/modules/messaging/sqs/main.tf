# ------ SQS QUEUE (ASYNC WORK / LOG EVENTS) ------

resource "aws_sqs_queue" "this" {
  name                       = "${var.name}-logs"
  visibility_timeout_seconds = var.visibility_timeout_seconds # How long a message stays hidden after a consumer receives it
  message_retention_seconds  = var.message_retention_seconds  # How long SQS keeps messages if they are not deleted
}
