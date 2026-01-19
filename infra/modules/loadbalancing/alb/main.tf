# ------ SECURITY GROUPS (EDGE + APP) ------

# ALB Security Group: allow inbound HTTP from anywhere
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

#Public entrypoint: allow HTTP from the internet (for health checks in tests)
  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Security Group: allow inbound ONLY from ALB SG to server port
resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs-sg"
  description = "ECS tasks security group"
  vpc_id      = var.vpc_id

# Only the ALB is allowed to reach the service port (prevents direct internet access)
  ingress {
    description     = "From ALB to server"
    from_port       = var.server_port
    to_port         = var.server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

# Outbound is open to allow image pulls (ECR), external APIs, and dependencies (via NAT/endpoints)
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------ APPLICATION LOAD BALANCER (PUBLIC) ------

resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.alb.id]
  subnets         = var.public_subnet_ids
}

# ------ TARGET GROUP (ECS TASKS AS IP TARGETS) ------

resource "aws_lb_target_group" "server" {
  name        = "${var.name}-server-tg"
  port        = var.server_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
  path                = "/api/health"
  healthy_threshold   = 2
  unhealthy_threshold = 2
  interval            = 30
  timeout             = 5
  matcher             = "200-399"
}

}

# ------ LISTENER (HTTP ENTRYPOINT) ------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }
}
