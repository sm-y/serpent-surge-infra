# serpent-surge-infra/terraform/ssm.tf
# Create IAM role with EC2 trust
# Attach `AmazonSSMManagedInstanceCore` policy
# Attach role to prod-ubuntu instance

# For existing prod-ubuntu instance to import into Terraform state 
# under the resource name aws_instance.prod_ubuntu.
# terraform import aws_instance.prod_ubuntu i-0cffd1a1c8d417f1a
# terraform plan
# will not try to recreate the instance but manage it.

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_role" {
  name               = "prod-ubuntu-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_role_policy" "ecr_policy" {
  name = "ECRFullAccess"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:ListImages"            # optional but useful
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "rds_describe_policy" {
  name = "RDSDescribeDBInstancesAccess"
  role = aws_iam_role.ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "rds:DescribeDBInstances"
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "prod-ubuntu-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "prod_ubuntu" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  associate_public_ip_address = true
  key_name               = var.key_name
  # iam_instance_profile   = var.iam_instance_profile_name
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "prod-ubuntu"
  }
}

# resource "aws_instance" "dev_ubuntu" {
#   ami                    = var.ami_id
#   instance_type          = "t3.micro"
  # (resource arguments)
# }
