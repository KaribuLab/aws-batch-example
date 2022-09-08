resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "tf_test_batch_exec_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}



resource "aws_iam_role" "ecs_instance_role" {
  name               = "ecs_instance_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": "ec2.amazonaws.com"
        }
    }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = "ecs_instance_role"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "aws_batch_service_role" {
  name               = "aws_batch_service_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Effect": "Allow",
          "Principal": {
          "Service": "batch.amazonaws.com"
          }
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "aws_batch_service_role" {
  role       = aws_iam_role.aws_batch_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

resource "aws_security_group" "sample" {
  name = "aws_batch_compute_environment_security_group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_batch_compute_environment" "sample" {
  compute_environment_name = "sample"

  compute_resources {
    max_vcpus = 2
    security_group_ids = [
      aws_security_group.sample.id
    ]
    subnets = [
      var.subnet_id
    ]
    type = "FARGATE"
  }

  service_role = aws_iam_role.aws_batch_service_role.arn
  type         = "MANAGED"
  depends_on   = [aws_iam_role_policy_attachment.aws_batch_service_role]
}

resource "aws_batch_job_queue" "sample" {
  name     = "tf-test-batch-job-queue"
  state    = "ENABLED"
  priority = 1
  compute_environments = [
    aws_batch_compute_environment.sample.arn
  ]
}

resource "aws_batch_job_definition" "sample" {
  name = "tf_test_batch_job_definition"
  type = "container"
  platform_capabilities = [
    "FARGATE",
  ]
  container_properties = <<EOF
{
  "command": ["/usr/local/bin/node", "/app/job.js"],
  "image": "601238391153.dkr.ecr.us-east-1.amazonaws.com/tf_test_batch_job_ecr",
  "fargatePlatformConfiguration": {
    "platformVersion": "LATEST"
  },
  "networkConfiguration": { 
    "assignPublicIp": "ENABLED"
  },
  "resourceRequirements": [
    {"type": "VCPU", "value": "0.25"},
    {"type": "MEMORY", "value": "512"}
  ],
  "executionRoleArn": "${aws_iam_role.ecs_task_execution_role.arn}"
}
EOF
}

resource "aws_ssm_parameter" "job_definition" {
  name  = "/batch-poc/aws-serverless/job-definition-arn"
  type  = "String"
  value = aws_batch_job_definition.sample.arn
}

resource "aws_ssm_parameter" "job_queue" {
  name  = "/batch-poc/aws-serverless/job-queue-arn"
  type  = "String"
  value = aws_batch_job_queue.sample.arn
}
