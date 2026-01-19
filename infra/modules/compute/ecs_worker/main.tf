    # ------ ECS TASK DEFINITION (CONSUMER WORKER) ------

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-consumer"
  network_mode             = "awsvpc" # Required for Fargate; each task gets its own ENI
  requires_compatibilities = ["FARGATE"] # Runs on Fargate (no EC2 host management)
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn # Used by ECS to pull images and ship logs
  task_role_arn            = var.task_role_arn

    # ------ CONTAINER DEFINITIONS (CONSUMER) ------

  container_definitions = jsonencode([
  {
    name      = "consumer"
    image     = var.ecr_image
    essential = true # Task is considered unhealthy if this container stops

    # ------ LOGGING (CLOUDWATCH LOGS) ------

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = var.log_group_name
        awslogs-region        = var.region
        awslogs-stream-prefix = "consumer"
      }
    }
    # ------ ENVIRONMENT VARIABLES ------

    environment = [
      for k, v in var.environment : {
        name  = k
        value = v
      }
    ]
  }
])
}
    # ------ ECS SERVICE (TASK LIFECYCLE MANAGER) ------

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
