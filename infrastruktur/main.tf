provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# EC2 Instance - FIXED to match current state
resource "aws_instance" "web" {
  ami                    = "ami-0229b8f55e5178b65"  # FIXED: Current AMI (don't change)
  instance_type          = "t2.micro"
  key_name               = "Eugenia"  # FIXED: Current key name (not grocerymate-key)
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = "grocery-ec2-role"  # ADDED: Current IAM profile

  tags = {
    Name = "GroceryMate"  # ADDED: Current tag
  }
}

# Web Security Group - FIXED to match current state
resource "aws_security_group" "web_sg" {
  name        = "launch-wizard-3"  # FIXED: Current exact name (not name_prefix)
  description = "launch-wizard-3 created 2025-06-27T11:24:44.860Z"  # FIXED: Current description

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000  # FIXED: Current is 3000, not 5000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow access to Docker application on port 5000"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Security Group - FIXED to match current state
resource "aws_security_group" "rds_sg" {
  name        = "GrosaryRDS"  # FIXED: Current exact name (typo preserved)
  description = "Created by RDS management console"  # FIXED: Current description

  # Splitting the rules to match how Terraform sees them in AWS
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
    cidr_blocks     = ["93.208.191.254/32"]  # Combined rule as AWS has it
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    ignore_changes = [ingress]  # Ignore ingress differences, AWS handles them differently
  }
}

# RDS Database - FIXED to match current state
resource "aws_db_instance" "default" {
  identifier             = "grocerymatedb"  # ADDED: Current identifier
  allocated_storage      = 20  # FIXED: Current is 20, not 10
  max_allocated_storage  = 1000  # ADDED: Current setting
  storage_encrypted      = true  # CRITICAL FIX: Must be true to prevent replacement

  db_name                = var.db_name
  engine                 = "postgres"
  engine_version         = "17.4"  # FIXED: Current is 17.4, not 15.13
  instance_class         = "db.t3.micro"

  username               = var.db_username
  password               = var.db_password

  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  performance_insights_enabled          = true  # ADDED: Current setting
  performance_insights_retention_period = 7     # ADDED: Current setting
  backup_retention_period               = 1     # ADDED: Current setting
  copy_tags_to_snapshot                 = true  # ADDED: Current setting

  lifecycle {
    ignore_changes = [password]  # Ignore password, Terraform doesn't know actual value
  }
}

resource "aws_s3_bucket" "avatars" {
    bucket = "grocerymate-jennys-avatars"

    tags = {
      Name = "grocerymate-jennys-avatars"
    }
}

