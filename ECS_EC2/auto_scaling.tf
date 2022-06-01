data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "ecs_launch_config" {
  name                        = "${var.cluster_prefix}-launch-config"
  image_id                    = "ami-06bb94c46ddc47feb" //ECS optimized aws image (operating system)
  iam_instance_profile        = aws_iam_instance_profile.ecs_agent.name
  security_groups             = [aws_security_group.ecs_sg.id]
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${var.cluster_prefix} >> /etc/ecs/ecs.config"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = var.access_keys
}

resource "aws_autoscaling_group" "ecs_autoscaling_group" {
  name                 = "${var.cluster_prefix}-autoSG"
  vpc_zone_identifier  = aws_subnet.public.*.id
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
}

## policy up
resource "aws_autoscaling_policy" "web_policy_up" {
  name                   = "${var.cluster_prefix}-policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300 //wait 300 seconds (5min) before increasing Auto Scaling Group again.
  autoscaling_group_name = aws_autoscaling_group.ecs_autoscaling_group.name
  policy_type            = "SimpleScaling"
}

## policy up alarm
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = "${var.cluster_prefix}_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"              // if 2 time (period=120seconds) the CPU uages is >= 70%
  metric_name         = "CPUUtilization" //if CPU usage is >= threshold (70%) for evaluation_periods (2) consecutive periods than take action (scale_adjustment by 1)
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70" // CPU usage percentage value

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ecs_autoscaling_group.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_up.arn]
}

## policy down
resource "aws_autoscaling_policy" "web_policy_down" {
  name                   = "${var.cluster_prefix}_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ecs_autoscaling_group.name
  policy_type            = "SimpleScaling"
}

## policy down alarm
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = "${var.cluster_prefix}_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ecs_autoscaling_group.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = [aws_autoscaling_policy.web_policy_down.arn]
}
