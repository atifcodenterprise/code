resource "aws_ecs_cluster" "ecs-ec2-cluster" {
  name = var.cluster_prefix //must be pass as a ECS_CLUSTER to user_data in auto_scaling.tf file
}

data "template_file" "ecs-task-container" {
  template = file("./templates/image/image.json")

  vars = {
    container_name = var.container_name
    app_image      = var.app_image
    app_port       = var.app_port
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    awslogs_group  = "/ecs/${lower(var.cluster_prefix)}"
  }
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family = var.task_name
  # execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn //for FARGATE ONLY
  # network_mode             = "awsvpc" //optional
  # requires_compatibilities = ["FARGATE"] //optional
  # cpu                   = var.fargate_cpu //optional
  # memory                = var.fargate_memory //optional
  container_definitions = data.template_file.ecs-task-container.rendered
  # volume {
  #   name = "APICodeVolume"

  #   efs_volume_configuration {
  #     # file_system_id          = "fs-08dd5735dacb60268"
  #     file_system_id          = "${aws_efs_file_system.efs.id}"
  #     root_directory          = "/"
  #     transit_encryption      = "DISABLED"
  #     # transit_encryption_port = null //optional
  #     # authorization_config { //optional
  #     #   access_point_id = null
  #     #   iam             = "DISABLED"
  #     # }
  #   }
  # }
}

resource "aws_ecs_service" "test-service" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.ecs-ec2-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count   = var.app_count
  # iam_role        = aws_iam_role.ecs_task_execution_role.arn // if launch_type = "FARGATE"
  # launch_type     = "FARGATE" // or "EC2" 

  ordered_placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  # network_configuration {
  #   security_groups  = [aws_security_group.ecs_sg.id]
  #   subnets          = aws_subnet.public.*.id
  #   assign_public_ip = true
  # }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb-tg.arn
    container_name   = var.container_name
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.alb_listener, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
