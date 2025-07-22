# terraform/main.tf

provider "aws" {
  region = var.aws_region
}

# VPC + subnets (existing, import)
resource "aws_vpc" "main" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.16.0/20"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.32.0/20"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.31.0.0/20"
  availability_zone       = "eu-north-1c"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Routes and security groups (existing, import)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "serpent-db-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]

  tags = {
    Name = "serpent-db-subnet-group"
  }
}

# Security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "serpent-rds-sg"
  description = "Allow MySQL access for Serpent Surge RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "MySQL access from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS MySQL database
resource "aws_db_instance" "serpent_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  identifier           = "serpent-surge-db"
  username             = "serpent_user"
  password             = "SecureUserPassword123!"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible  = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

# S3 bucket
resource "aws_s3_bucket" "backup_bucket" {
  bucket = "serpent-backup-1"
}

terraform {
  backend "s3" {
    bucket = "serpent-backup-1"
    key    = "serpent/terraform.tfstate"
    region = "eu-north-1"
  }
}

# S3 bucket ACL (new)
# resource "aws_s3_bucket_acl" "backup_bucket_acl" {
#   bucket = aws_s3_bucket.backup_bucket.id
#   acl    = "private"
# }

# ECR repo
# resource "aws_ecr_repository" "repo" {
#   name = "serpent-surge-repo"
# }

# ECR repos

resource "aws_ecr_repository" "ecr_backend_1" {
  name = "serpent-repo-backend"
}

resource "aws_ecr_repository" "ecr_frontend_1" {
  name = "serpent-repo-frontend"
}

# resource "aws_ecr_repository" "ecr_nginx" {
#   name = "serpent-repo-nginx"
# }

# Lifecycle policies

resource "aws_ecr_lifecycle_policy" "ecr_backend_policy" {
  repository = aws_ecr_repository.ecr_backend_1.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images"
        selection = {
          tagStatus     = "untagged"
          countType     = "imageCountMoreThan"
          countNumber   = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "ecr_frontend_policy" {
  repository = aws_ecr_repository.ecr_frontend_1.name

  policy = aws_ecr_lifecycle_policy.ecr_backend_policy.policy
}

# resource "aws_ecr_lifecycle_policy" "ecr_nginx_policy" {
#   repository = aws_ecr_repository.ecr_nginx.name
# 
#   policy = aws_ecr_lifecycle_policy.ecr_backend_policy.policy
# }

# EFS
resource "aws_efs_file_system" "efs" {
  creation_token = "serpent-efs-token"
  tags = {
    Name = "serpent-efs"
  }
}

resource "aws_security_group" "efs_sg" {
  name        = "serpent-efs-sg"
  description = "Allow NFS access to EFS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "NFS from VPC"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["172.31.0.0/16"]  # VPC CIDR
  }

  egress {
    description      = "Allow all outbound"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# EFS mount
resource "aws_efs_mount_target" "efs_mount" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private1.id
  security_groups = [aws_security_group.rds_sg.id, aws_security_group.efs_sg.id]
}
