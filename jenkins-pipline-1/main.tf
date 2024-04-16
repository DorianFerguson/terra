# Create an EC2 instance
resource "aws_instance" "jenkins-pipeline" {
  ami                  = var.ami_id
  instance_type        = var.instance
  #count                = 1
  key_name             = var.key_name
  user_data            = file("script.sh")  # Use user data script for instance setup
  iam_instance_profile = aws_iam_instance_profile.s3_read_write_access_profile.name
  tags = {
    Name = "old-man-jenkins"
  }
  vpc_security_group_ids = [aws_security_group.terraform-sg.id]  # Attach security group
}

# Create an S3 bucket for Jenkins artifacts
resource "aws_s3_bucket" "jenkins-bucket" {
  bucket = var.bucketname

  tags = {
    Name        = "jenkins-artifacts"
    Environment = "Dev"
  }
}

# Retrieve information about the default VPC
data "aws_vpc" "default" {
  default = true
}

# Define a security group for the EC2 instance
resource "aws_security_group" "terraform-sg" {
  name   = "terraform-sg"
  vpc_id = data.aws_vpc.default.id

  # Allow SSH traffic from specified IP address
  ingress {
    description = "Allows SSH traffic from my IP"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["${var.my_Ip}"]
  }

  # Allow all traffic on specified port
  ingress {
    description = "Allows all traffic on port specified port"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Define an IAM role for granting S3 read/write access to EC2 instances
resource "aws_iam_role" "s3_read_write_access_role" {
  name = "s3_read_write_access_role"

  # Define trust relationship policy
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Define an IAM policy for granting S3 read/write access
resource "aws_iam_policy" "s3_read_write_access_policy" {
  name = "test_policy"

  # Define policy document
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:GetObject",
          "s3:List*",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::${var.bucketname}/*"
      }
    ]
  })
}

# Attach IAM policy to IAM role
resource "aws_iam_role_policy_attachment" "s3_read_write_access_attach" {
  role       = aws_iam_role.s3_read_write_access_role.name
  policy_arn = aws_iam_policy.s3_read_write_access_policy.arn
}

# Define IAM instance profile
resource "aws_iam_instance_profile" "s3_read_write_access_profile" {
  name = "ec2-rw-s3"
  role = aws_iam_role.s3_read_write_access_role.name
}
