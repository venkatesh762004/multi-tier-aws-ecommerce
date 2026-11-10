
resource "aws_lb" "frontend_alb" {
  name               = "ecommerce-frontend-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.main["public_1a"].id,
    aws_subnet.main["public_1b"].id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "ecommerce-frontend-alb"
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "ecommerce-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "ecommerce-frontend-tg"
  }
}
