resource "aws_autoscaling_group" "frontend" {
  name             = "${var.project_name}-frontend-asg"
  min_size         = 1
  max_size         = 2
  desired_capacity = 2

  vpc_zone_identifier = [
    aws_subnet.main["app_1a"].id,
    aws_subnet.main["app_1b"].id
  ]

  target_group_arns = [
    aws_lb_target_group.frontend_tg.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecommerce-frontend-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "Frontend"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_group" "backend" {
  name             = "${var.project_name}-backend-asg"
  min_size         = 1
  max_size         = 2
  desired_capacity = 2

  vpc_zone_identifier = [
    aws_subnet.main["app_1a"].id,
    aws_subnet.main["app_1b"].id
  ]

  target_group_arns = [
    aws_lb_target_group.backend_tg.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ecommerce-backend-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "Backend"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_policy" "backend_cpu" {
  name                   = "${var.project_name}-backend-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.backend.name
  policy_type            = "TargetTrackingScaling"

  estimated_instance_warmup = 180

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}