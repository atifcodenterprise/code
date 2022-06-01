variable "cluster_prefix" {
  default     = "OrangutanCluster"
  description = "Orangebuddies APIs"
  #replace the region as suits for your requirement
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "default cidr block for VPC"
  #replace the region as suits for your requirement
}

variable "aws_region" {
  default     = "eu-west-1"
  description = "aws region where our resources going to create choose"
  #replace the region as suits for your requirement
}

variable "az_count" {
  default     = "2"
  description = "number of availability zones in above region"
}

variable "ecs_task_execution_role" {
  default     = "myECcsTaskExecutionRole"
  description = "ECS task execution role name"
}

variable "app_image" {
  //default     = "134132357646.dkr.ecr.eu-west-1.amazonaws.com/orangebuddies-repo:php74-apache"
  default     = "rehanislam/orangutan:latest"
  description = "docker image to run in this ECS cluster"
}

variable "app_port" {
  default     = "5000"
  description = "portexposed on the docker image"
}

variable "app_count" {
  default     = "1" #choose 2 bcz i have choosen 2 AZ
  description = "numer of docker containers to run"
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  default     = "1024"
  description = "fargate instacne CPU units to provision,my requirent 1 vcpu so gave 1024"
}

variable "fargate_memory" {
  default     = "512"
  description = "Fargate instance memory to provision (in MiB) not MB"
}

variable "container_name" {
  default     = "orangutancluster-container"
  description = "Container name"
}
variable "service_name" {
  default     = "orangutancluster-service"
  description = "Service name"
}

variable "task_name" {
  default     = "orangutancluster-task"
  description = "Task name"
}

variable "alb_name" {
  default     = "orangutancluster-load-balancer"
  description = "ALB name"
}

variable "alb_tg_name" {
  default     = "orangutancluster-alb-tg"
  description = "ALB TG name"
}

variable "access_keys" {
  default     = "aws-key-pair"
  description = "AWS Key Pair"
}
