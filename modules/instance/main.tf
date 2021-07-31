
data "aws_availability_zones" "a_z" {}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_launch_configuration" "server" {
  name_prefix = "Server-instance-"

  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = var.security_groups
  user_data       = var.user_data
  key_name        = var.pair_key

  associate_public_ip_address = var.public_ip_address

  lifecycle {
    create_before_destroy = true
  }
}

output "launch_configuration_id" {
  value = aws_launch_configuration.server.id
}
