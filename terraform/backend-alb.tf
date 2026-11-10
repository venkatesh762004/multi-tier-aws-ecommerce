resource "aws_lb" "backend_alb" {
  name               = "ecommerce-backend-alb"
  internal           = true
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.backend_alb_sg.id
  ]

  subnets = [
    aws_subnet.main["app_1a"].id,
    aws_subnet.main["app_1b"].id
  ]

  tags = {
    Name = "ecommerce-backend-alb"
  }
}

resource "aws_lb_target_group" "backend_tg" {
  name        = "ecommerce-backend-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}