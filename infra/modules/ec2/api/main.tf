resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-api-sg"
  description = "${var.project_name} security group"
  vpc_id      = var.vpc_id

  ingress {
    description = "all-http-traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "all-https-traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "all-outbound-traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

resource "aws_iam_policy" "deployment_bucket_read_and_write" {
  name = "${var.project_name}-deployment-s3-read-and-write"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::${var.deployment_s3_bucket_name}",
          "arn:aws:s3:::${var.deployment_s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "assume_user_observer_roles" {
  name = "${var.project_name}-assume-user-observer-roles"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = "arn:aws:iam::*:role/VitruviuxObserverRole-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_deployment_read_and_write" {
  role       = var.ssm_role_name
  policy_arn = aws_iam_policy.deployment_bucket_read_and_write.arn
}

resource "aws_iam_role_policy_attachment" "attach_assume_user_observer_roles" {
  role       = var.ssm_role_name
  policy_arn = aws_iam_policy.assume_user_observer_roles.arn
}

resource "aws_instance" "api" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.project_name
  user_data_base64            = var.user_data
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = var.ssm_profile_name

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${var.project_name}-api"
  }
}
