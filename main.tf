resource "aws_vpc" "vpc_db_handson" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc-db-handson-2"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "handson_subnet" {
  vpc_id            = aws_vpc.vpc_db_handson.id
  cidr_block        = var.subnets
  availability_zone = var.availability_zone_ohio
  tags = {
    Name = "subnet1--handson"
  }
}

resource "aws_subnet" "handson_subnet2" {
  vpc_id            = aws_vpc.vpc_db_handson.id
  cidr_block        = var.subnets2
  availability_zone = var.availability_zone_ohio_2
  tags = {
    Name = "subnet2--handson"
  }
}

resource "aws_subnet" "handson_subnet3" {
  vpc_id            = aws_vpc.vpc_db_handson.id
  cidr_block        = var.subnets3
  availability_zone = var.availability_zone_ohio_3
  tags = {
    Name = "subnet2--handson"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.vpc_db_handson.id
  tags = {
    Name = "my_igw"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.vpc_db_handson.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "my_subnet_associations" {
  count          = length(aws_subnet.handson_subnet[*].id)
  subnet_id      = aws_subnet.handson_subnet2.id
  route_table_id = aws_route_table.my_route_table.id
}

# Define 3 availability zones
# variable "availability_zones" {
#   default = ["us-east-2a", "us-east-2b", "us-east-2c"]
# }

# Define subnets across availability zones
# resource "aws_subnet" "handson_subnet" {
#   count                  = 9
#   vpc_id                 = aws_vpc.vpc_db_handson.id
#   cidr_block             = cidrsubnet(aws_vpc.vpc_db_handson.cidr_block, 4, count.index)
#   availability_zone      = element(var.availability_zones, count.index % length(var.availability_zones))
#   map_public_ip_on_launch = true  # For public subnets

#   tags = {
#     Name = "subnet-${count.index}"
#   }
# }

resource "aws_instance" "devopspro-handson" {
  ami                         = "ami-0b59bfac6be064b78"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.handson_subnet.id
  key_name                    = aws_key_pair.lauro_user_ssh_key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  count                       = var.wp_vm_count
  tags = {
    Name = "ec2-devopspro-handson-${count.index}"
  }
}

resource "aws_ebs_volume" "nfs_volume" {
  availability_zone = aws_instance.devopspro-handson[1].availability_zone
  size              = 10
  type              = "gp2"
  tags = {
    Name = "nfs-volume-handon"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.nfs_volume.id
  instance_id = aws_instance.devopspro-handson[1].id
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.handson_subnet2.id, aws_subnet.handson_subnet3.id]
}

resource "aws_db_instance" "db_instance_handson" {
  identifier           = "database-handson"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  engine               = "mysql"
  multi_az             = false
  username             = "user1_name"
  password             = "password1"
  engine_version       = "8.0.35"
  skip_final_snapshot  = true
  storage_type         = "gp2"
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name

  tags = {
    Name = "db_instance_mysql"
  }
}

resource "aws_lb" "example" {
  name               = "example-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_ssh_http.id]

  subnet_mapping {
    subnet_id = aws_subnet.handson_subnet.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.handson_subnet2.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.handson_subnet3.id
  }
  
  tags = {
    Name = "loadbalancer-handson"
  }
}

resource "aws_lb_target_group" "example" {
  name     = "example-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_db_handson.id
  tags = {
    Name = "lb_targetgroup-handson"
  }

  health_check {
    protocol            = "HTTP"
    port                = 80
    path                = "/health"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.devopspro-handson[0].id
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"
  count             = length(var.subnets)
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
  tags = {
    Name = "lb_listener_handson"
  }
}


resource "aws_iam_user" "lauro" {
  name = "lauro"
  path = "/"
}

resource "aws_key_pair" "lauro_user_ssh_key" {
  key_name   = "sshkey-test-lauro-user"
  public_key = file("~/.ssh/testssh.pub")
  tags = {
    Name = "sshkey-test-lauro-user"
  }
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP traffic on EC2 instance"
  vpc_id      = aws_vpc.vpc_db_handson.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH to EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security-group-handson"
  }
}