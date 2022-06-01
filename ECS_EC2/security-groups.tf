# security group creation and attcahing in ecs, alb etc

# ALB Security Group: Edit to restrict access to the application
resource "aws_security_group" "alb-sg" {
  name        = "${var.cluster_prefix}-load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = var.app_port
    to_port     = var.app_port
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_prefix}-alb-sg"
  }
}

# this security group for ecs - Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_sg" {
  name        = "${var.cluster_prefix}-ecs-tasks-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    # security_groups = [aws_security_group.alb-sg.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_prefix}-ecs-sg"
  }
}

# security group for EFS disk
# resource "aws_security_group" "efs-sg" {
#   name        = "${var.cluster_prefix}-efs-sg"
#   description = "Allos inbound efs traffic from ec2"
#   vpc_id      = aws_vpc.my-vpc.id

#   ingress {
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port   = 2049
#     to_port     = 2049
#     protocol    = "tcp"
#   }

#   egress {
#     protocol    = "-1"
#     from_port   = 0
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# security group for RDS (mysql)
# resource "aws_security_group" "rds_sg" {
#   name        = "${var.cluster_prefix}-rds-security-group"
#   description = "security group for rds mysql"
#   vpc_id      = aws_vpc.my-vpc.id

#   ingress {
#     protocol        = "tcp"
#     from_port       = 3306
#     to_port         = 3306
#     cidr_blocks     = ["0.0.0.0/0"]
#     security_groups = [aws_security_group.ecs_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.cluster_prefix}-rds-sg"
#   }
# }
