# Create the log group for the ECS task
resource "aws_cloudwatch_log_group" "logs" {
  name              = "/${var.log_group}/${var.family}"
  retention_in_days = 1 # You can adjust this as needed

  tags = {
    Name = "${var.log_group}-log-group"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.image
      cpu       = var.cpu
      memory    = var.memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ],
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/welcome || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      },
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.logs.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      # 🚀 Dynamic Injection of Standard Variables
      # Standard Env Vars
      environment = [
        for k, v in var.environment_vars : { name = k, value = v }
      ]

      # 🔐 Dynamic Injection of Secrets
      secrets = [
        for k, arn in var.aws_secret_arns : {
          name      = k
          valueFrom = arn
        }
      ]
    }
  ])
}