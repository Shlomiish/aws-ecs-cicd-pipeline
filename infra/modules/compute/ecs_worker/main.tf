resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-consumer"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
  {
    name      = "consumer"
    image     = var.ecr_image
    essential = true

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group_name
        awslogs-region        = var.region
        awslogs-stream-prefix = "consumer"
      }
    }

    environment = [
      for k, v in var.environment : {
        name  = k
        value = v
      }
    ]
  }
])
}

resource "aws_ecs_service" "this" {
  name            = "${var.name}-consumer-svc"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }
}
