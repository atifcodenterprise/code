resource "aws_security_group" "aws_sg" {
  name = "security group from TF"

  ingress {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "80 from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}




resource "aws_instance" "aws_ins_web" {

  ami                         = "ami-06bb94c46ddc47feb"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.aws_sg.id]
  associate_public_ip_address = true
  key_name                    = "aws-key-pair" # your key here

  tags = {
    Name = "my own instance2"
  }

}

output "instance_ip" {
  value = aws_instance.aws_ins_web.public_ip
}
