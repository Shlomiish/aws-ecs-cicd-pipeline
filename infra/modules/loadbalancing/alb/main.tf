# ALB Security Group: allow inbound HTTP from anywhere
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

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

  ingress {
    description     = "From ALB to server"
    from_port       = var.server_port
    to_port         = var.server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  internal           = false

  security_groups = [aws_security_group.alb.id]
  subnets         = var.public_subnet_ids
}

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

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }
}
