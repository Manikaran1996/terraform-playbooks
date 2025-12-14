data "aws_iam_policy_document" "n8n_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "n8n_ecs_task_execution_role" {
  name               = "n8n-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.n8n_assume_role_policy.json
}

resource "aws_iam_policy" "n8n_ecs_task_execution_role_policy" {
  name = "ECS-Task-Execution-Role-Policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow",
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
        ],
        Resource = ["*"]
      }
    ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "n8n_ecs_task_execution_role_attachment" {
  role       = aws_iam_role.n8n_ecs_task_execution_role.id
  policy_arn = aws_iam_policy.n8n_ecs_task_execution_role_policy.arn
}

resource "aws_iam_role" "n8n_ecs_task_role" {
  name               = "n8n-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.n8n_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "n8n_ecs_task_role_attachment" {
  role       = aws_iam_role.n8n_ecs_task_role.id
  policy_arn = aws_iam_policy.n8n_ecs_task_execution_role_policy.arn
}
