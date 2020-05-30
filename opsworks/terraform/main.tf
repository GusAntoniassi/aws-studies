provider "aws" {
    version = "~> 2.0"
    region = "us-east-1"
}

locals {
    s3_bucket_name = "russia-testes-gerais"
}

resource "aws_iam_role" "opsworks_service_role" {
    name_prefix = "gus-opsworks"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "opsworks.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "opsworks_service_policy" {
    name_prefix = "gus-opsworks-service"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:*",
                "iam:PassRole",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:DescribeAlarms",
                "ecs:*",
                "elasticloadbalancing:*",
                "rds:*"
            ],
            "Effect": "Allow",
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "opsworks_service_policy_attachment" {
    name = "opsworks-svc-policy"
    policy_arn = "${aws_iam_policy.opsworks_service_policy.arn}"
    roles = ["${aws_iam_role.opsworks_service_role.name}"]
}

resource "aws_iam_instance_profile" "opsworks_instance_profile" {
  name_prefix = "gus-opsworks"
  role = "${aws_iam_role.opsworks_instance_role.name}"
}

resource "aws_iam_role" "opsworks_instance_role" {
  name = "test_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_opsworks_stack" "default" {
    name = "gus-stack"
    service_role_arn = "${aws_iam_role.opsworks_service_role.arn}"
    default_instance_profile_arn = "${aws_iam_instance_profile.opsworks_instance_profile.arn}"
    agent_version = "LATEST"
    configuration_manager_name = "Chef"
    configuration_manager_version = "12"
    default_ssh_key_name = "gus@samsung"
    region = "us-east-1"
    vpc_id = "vpc-fd37ae87"
    default_subnet_id = "subnet-905c17be"
    use_custom_cookbooks = true
    custom_cookbooks_source {
        type = "s3"
        url = "https://s3-us-east-1.amazonaws.com/${local.s3_bucket_name}/opsworks-demo.zip"
        revision = ""
    }

    custom_json = <<EOT
{
    "foobar": {
        "version": "1.0.0"
    }
}
EOT
}