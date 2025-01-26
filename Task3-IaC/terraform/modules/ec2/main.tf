resource "aws_instance" "app_instance" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id
  key_name      = var.key_name

  security_group_names = [var.security_group]

  tags = {
    Name = "app-instance"
  }
}

resource "aws_eip" "app_eip" {
  instance = aws_instance.app_instance.id
}
