resource "aws_elb" "server" {
  name = var.elb_name

  security_groups = var.security_groups
  subnets         = var.subnet_ids

  cross_zone_load_balancing = var.cross_zone_balancing

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  tags = {
    Name = "elb-dev"
  }
}

resource "aws_autoscaling_group" "server" {
  name = "auto-scal-server"

  desired_capacity = 2
  min_size         = 1
  max_size         = 5

  launch_configuration = var.launch_configuration
  load_balancers       = [aws_elb.server.name]
  health_check_type    = "ELB"
  vpc_zone_identifier  = var.subnet_ids

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  # dynamic "tag" {
  #   for_each = {
  #     Name   = "Nginx-in-AutoScaling"
  #     Owner  = "Umbrella.Today"
  #     TAGKEY = "TAGVALUE"
  #   }
  #   content {
  #     key                 = tag.key
  #     value               = tag.value
  #     propagate_at_launch = true
  #   }
  # }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "policy_up" {
  name                   = "policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.server.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_up" {
  alarm_name          = "cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.server.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.policy_up.arn]
}

resource "aws_autoscaling_policy" "policy_down" {
  name                   = "policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.server.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_down" {
  alarm_name          = "cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.server.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.policy_down.arn]
}

#---------------------------------------------------------------------------------
output "elb_url" {
  value = aws_elb.server.dns_name
}
