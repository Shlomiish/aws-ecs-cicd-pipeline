# ------ ECS CLUSTER (LOGICAL GROUPING) ------

resource "aws_ecs_cluster" "this" {
  name = "${var.name}-cluster"
}

# ------ ECS TASK DEFINITION (WHAT TO RUN) ------

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name}-server"
  network_mode             = "awsvpc" # Required for Fargate; each task gets its own ENI in the VPC
  requires_compatibilities = ["FARGATE"] # in fargate, each task is a self network unit in the vpc (like host that has container)
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn        = var.execution_role_arn
  task_role_arn             = var.task_role_arn

# ------ CONTAINER DEFINITIONS (SERVER) ------

  container_definitions = jsonencode([
  {
    name      = "server"
    image     = var.ecr_image
    essential = true # If this container stops, the task is considered failed

    portMappings = [
      {
        containerPort = var.container_port #Port exposed by the container
        hostPort      = var.container_port #because fargate is like host, so we need to open port in the "host"
        protocol      = "tcp"
      }
    ]
  
  # ------ LOGGING (CLOUDWATCH LOGS) ------

    logConfiguration = { 
      logDriver = "awslogs" # Sends container stdout/stderr to CloudWatch Logs
      options = {
        awslogs-group         = var.log_group_name
        awslogs-region        = var.region
        awslogs-stream-prefix = "server"
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
  name            = "${var.name}-server-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "server"
    container_port   = var.container_port
  }

  depends_on = [aws_ecs_task_definition.this]
}

