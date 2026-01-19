# data "aws_iam_policy_document" "ecs_task_assume_role" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# # Execution role: pull from ECR + write logs to CloudWatch
# resource "aws_iam_role" "execution" {
#   name               = "${var.name}-ecs-execution-role"
#   assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
# }

# resource "aws_iam_role_policy_attachment" "execution_policy" {
#   role       = aws_iam_role.execution.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# # Task role: for the app itself
# resource "aws_iam_role" "task" {
#   name               = "${var.name}-ecs-task-role"
#   assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
# }


# ------ IAM ASSUME ROLE POLICY (ECS TASKS) ------

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"] # Allows ECS tasks to assume IAM roles (ECS TASK EXECUTION ROLE and ECS TASK ROLE) via temporary STS (Security Token Service)

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"] # Trusted AWS service that can assume this role
    }
  }
}

# ------ ECS TASK EXECUTION ROLE ------

# Execution role = managed policy, its give permission to pull from ECR + write logs to CloudWatch
resource "aws_iam_role" "execution" {
  name               = "${var.name}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json # Trust policy for ECS tasks
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" # Managed policy for ECR + CloudWatch access
}

# ------ ECS TASK ROLE (APPLICATION PERMISSIONS) ------

# Task role: for the app itself (permission consumer "talking" to sqs)
resource "aws_iam_role" "task" {
  name               = "${var.name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json # Used by the running application containers
}
