provider "aws" {
  region = "us-east-1"  # 👈 set your desired region here
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix          = "ecs"
  vpc_cidr             = "10.0.0.0/16"
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "alb_sg" {
  source = "./modules/security-group"

  name   = "alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  # Default egress is already set to allow all outbound traffic
}

module "ecs_sg" {
  source = "./modules/security-group"

  name   = "ecs-tasks-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = var.container_port
      to_port         = var.container_port
      protocol        = "tcp"
      cidr_blocks     = []
      security_groups = [module.alb_sg.security_group_id]
    }
  ]
  # Default egress is already set to allow all outbound traffic
}

module "iam" {
  source                   = "./modules/iam"
  name_prefix              = "ecs"
  attach_cloudwatch_policy = true
  attach_ssm_policy        = false
  create_custom_task_policy = true
  
  # Add custom policy for execution role
  create_custom_execution_policy = true
  custom_execution_policy_json = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:logs:<REGION>:<ACCOUNT_ID>:log-group:/aws/ecs/*",
          "arn:aws:logs:<REGION>:<ACCOUNT_ID>:log-group:/aws/ecs/*:log-stream:*"
        ]
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })

  custom_task_policy_json = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [
          "arn:aws:s3:::my-secure-bucket",
          "arn:aws:s3:::my-secure-bucket/*"
        ]
      }
    ]
  })
}


module "ecs" {
  source      = "./modules/ecs"
  name_prefix = "ecs"
  environment = "dev"

  enable_container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]
}


module "ecs_task_definition" {
  source             = "./modules/task-definition"

  family             = var.container_name
  cpu                = var.cpu
  memory             = var.memory
  container_name     = var.container_name
  image              = var.container_image
  container_port     = var.container_port
  region             = var.region

  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
}

module "ecs_service" {
  source                         = "./modules/ecs_service"

  name_prefix                    = "ecs"
  cluster_id                     = module.ecs.cluster_id
  task_definition_arn           = module.ecs_task_definition.task_definition_arn
  desired_count                 = var.desired_count
  target_group_arn              = module.alb.target_group_arn
  container_name                = var.container_name
  container_port                = var.container_port

  force_new_deployment              = true
  health_check_grace_period_seconds = 60

  private_subnet_ids            = module.vpc.private_subnet_ids
  security_group_ids            = [module.ecs_sg.security_group_id]
  environment                   = var.environment
}


module "alb" {
  source              = "./modules/alb"
  name_prefix         = "ecs"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  security_group_ids  = [module.alb_sg.security_group_id]
  target_port         = var.container_port
  environment         = var.environment
}
