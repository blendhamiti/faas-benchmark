resource "aws_vpc" "db" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc_db"
  }
}

resource "aws_subnet" "db1" {
  vpc_id            = aws_vpc.db.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "db_subnet1"
  }
}

resource "aws_subnet" "db2" {
  vpc_id            = aws_vpc.db.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "db_subnet2"
  }
}

resource "aws_subnet" "db3" {
  vpc_id            = aws_vpc.db.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "db_subnet3"
  }
}

resource "aws_db_subnet_group" "db_group" {
  name       = "db_group"
  subnet_ids = [aws_subnet.db1.id, aws_subnet.db2.id, aws_subnet.db3.id]

  tags = {
    Name = "subnet_group_db"
  }
}

resource "aws_security_group" "security_group_db" {
  name        = "security_group_db"
  description = "Allow inbound and outbound traffic"
  vpc_id      = aws_vpc.db.id

  ingress {
    from_port   = 3306
    to_port     = 3306
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
    Name = "security_group_db"
  }
}

resource "aws_db_parameter_group" "parameter_group_db" {
  name   = "db"
  family = "mysql5.7"

  #   parameter {
  #     name  = "log_connections"
  #     value = "1"
  #   }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.db.id

  tags = {
    Name = "db_gw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.db.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  # route {
  #   cidr_block = aws_subnet.db1.cidr_block
  #   gateway_id = aws_internet_gateway.gw.id
  # }

  # route {
  #   cidr_block = aws_subnet.db2.cidr_block
  #   gateway_id = aws_internet_gateway.gw.id
  # }

  # route {
  #   cidr_block = aws_subnet.db3.cidr_block
  #   gateway_id = aws_internet_gateway.gw.id
  # }
  tags = {
    Name = "db"
  }
}

resource "aws_route_table_association" "db1" {
  subnet_id      = aws_subnet.db1.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "db2" {
  subnet_id      = aws_subnet.db2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "db3" {
  subnet_id      = aws_subnet.db3.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_db_instance" "default" {
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  db_name                = "seeu_db"
  username               = "admin"
  password               = "admin123"
  apply_immediately      = true
  skip_final_snapshot    = true
  publicly_accessible    = true
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [aws_security_group.security_group_db.id]
  parameter_group_name   = aws_db_parameter_group.parameter_group_db.name
}
