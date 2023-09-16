data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "dvwa" {
  instance_type          = "t4g.small"
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = aws_subnet.public["public-a"].id
  vpc_security_group_ids = [aws_security_group.dvwa.id]
  iam_instance_profile   = aws_iam_instance_profile.ssm.name
  user_data              = file("userdata.sh")

  tags = {
    Name = "terraform-dvwa"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "dvwa" {
  name        = "terraform-dvwa"
  description = "allow 80"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "dvwa web"
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

resource "aws_lb" "dvwa" {
  name               = "terrafomr-dvwa2"
  load_balancer_type = "network"

  dynamic "subnet_mapping" {
    for_each = aws_subnet.public

    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  tags = {
    Name = "terraform-dvwa"
  }
}

resource "aws_lb_target_group" "dvwa" {
  name     = "http"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    port     = 80
    protocol = "TCP"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "dvwa" {
  load_balancer_arn = aws_lb.dvwa.id
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.dvwa.id
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "dvwa" {
  target_group_arn = aws_lb_target_group.dvwa.arn
  target_id        = aws_instance.dvwa.id
  port             = 80
}
