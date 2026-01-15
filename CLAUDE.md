# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Terraform Infrastructure-as-Code (IaC) project that provisions an AWS ECS Fargate environment with supporting infrastructure including VPC, ALB, IAM roles, secrets management, and artifact storage. The infrastructure is designed to run containerized applications with integrated CI/CD support.

## Essential Commands

### Terraform Workflow
```bash
# Initialize Terraform and download providers
terraform init

# Validate configuration syntax
terraform validate

# Preview changes before applying
terraform plan

# Apply infrastructure changes
terraform apply

# Destroy all infrastructure (use with caution)
terraform destroy

# Format Terraform files to canonical style
terraform fmt -recursive

# Show current state
terraform show

# List all resources in state
terraform state list
```

### Working with Specific Resources
```bash
# Target specific module or resource
terraform plan -target=module.ecs_service
terraform apply -target=module.secrets

# Refresh state to match real infrastructure
terraform refresh

# View outputs after apply
terraform output
terraform output alb_endpoint
```

## Architecture Overview

### Module Structure
The infrastructure is organized into reusable modules under `modules/`:

- **vpc**: Creates VPC with public/private subnets across multiple AZs
- **security-group**: Manages security groups for ALB and ECS tasks
- **alb**: Application Load Balancer for traffic distribution
- **ecs**: ECS cluster with Fargate capacity providers
- **ecs_service**: ECS service configuration with auto-scaling capabilities
- **task-definition**: ECS task definitions with container specs and logging
- **iam**: IAM roles and policies for ECS execution and task roles
- **secrets_manager**: AWS Secrets Manager integration for sensitive data
- **s3**: S3 bucket for build artifacts
- **ecr**: ECR repository (currently commented out in main.tf)

### Data Flow and Dependencies

1. **Network Layer**: VPC module creates the foundation with public/private subnets
2. **Security**: Security groups control traffic between ALB and ECS tasks
3. **IAM**: Execution role (pulls images, writes logs) and Task role (runtime permissions)
4. **Secrets**: Secrets Manager stores sensitive environment variables
5. **Compute**: ECS cluster runs Fargate tasks defined by task definitions
6. **Load Balancing**: ALB distributes traffic to ECS tasks on private subnets
7. **Storage**: S3 bucket stores build artifacts for CI/CD pipeline

### Critical Integration Points

**Task Definition to Secrets Manager** (modules/task-definition/main.tf:56-61):
- Task definitions dynamically inject secrets from AWS Secrets Manager
- Secrets are passed as environment variables to containers
- The `secrets` block references ARNs from the secrets_manager module

**IAM Execution Role Permissions** (main.tf:75-102):
- Execution role needs ECR pull permissions, CloudWatch Logs write access
- Task role has custom policies for S3 access and Secrets Manager read access
- Secret ARNs from secrets_manager module are passed to IAM module (main.tf:121)

**Secrets Manager with GCP Key File** (modules/secrets_manager/main.tf:23-27):
- Special handling for GCP_KEY_JSON secret that reads from local file
- File path provided via `gcp_key_file_path` variable in main.tf:208
- Other secrets use defaults from `secret_defaults` variable or "PENDING_MANUAL_UPDATE"

### State Management

Backend is configured in `backend.tf` with:
- S3 bucket: `rnd-ecs-terraform-state`
- State path: `terraform-rnd/terraform.tfstate`
- Encryption enabled
- Note: DynamoDB locking is commented out (line 7)

Before first use, ensure the S3 bucket exists (see README.md for setup commands).

## Configuration Details

### Environment Variables and Secrets

**Non-sensitive variables** are stored in `variables.tf` and can be overridden via:
- `terraform.tfvars` file
- Command line: `-var="key=value"`
- Environment variables: `TF_VAR_key=value`

**Sensitive secrets** are defined in `locals.tf` under `sensitive_keys` list and include:
- Database credentials (MONGODB_URI)
- API keys (SENDGRID_API_KEY, GOOGLE_MAPS_API_KEY, etc.)
- Authentication secrets (PRIVATE_KEY, PUBLIC_KEY, SECRET_KEY)
- Third-party service credentials (ZOHO, SENTRY, CELCOM, etc.)
- GCP service account key (GCP_KEY_JSON - loaded from google-gcp-key-dev.json)

**Application environment variables** (`app_env_vars`) are passed to the task definition as standard environment variables (non-sensitive configuration).

### Health Checks

The task definition includes a container health check (modules/task-definition/main.tf:34-40):
- Endpoint: `http://localhost:3000/welcome`
- Interval: 30 seconds
- Timeout: 5 seconds
- Retries: 3
- Start period: 60 seconds

Ensure your containerized application exposes this endpoint.

### Capacity Providers

ECS cluster uses mixed capacity provider strategy (main.tf:132-140):
- FARGATE (base=1, weight=1) for guaranteed capacity
- FARGATE_SPOT available for cost optimization
- Container Insights enabled for monitoring

## Common Workflows

### Deploying Infrastructure Changes

1. Make changes to `.tf` files
2. Run `terraform fmt` to format code
3. Run `terraform validate` to check syntax
4. Run `terraform plan` to review changes
5. Run `terraform apply` to deploy

### Updating Container Image

To deploy a new container image:
1. Update `container_image` variable in `variables.tf` or via tfvars
2. Apply with force deployment: The service already has `force_new_deployment = true` (main.tf:174)
3. Run `terraform apply` - this will trigger a new task deployment

### Managing Secrets

Secrets are created with lifecycle `ignore_changes` to prevent Terraform from overwriting manual updates:

1. **Initial creation**: Secrets use defaults or "PENDING_MANUAL_UPDATE"
2. **Update via AWS Console or CLI**:
   ```bash
   aws secretsmanager update-secret \
     --secret-id terraform-rnd-app/dev/SECRET_KEY \
     --secret-string "new-value"
   ```
3. Terraform will not overwrite manual changes on subsequent applies

### Adding New Secrets

1. Add secret key name to `sensitive_keys` list in `locals.tf`
2. Optionally add default value to `secret_defaults` variable
3. Run `terraform apply` to create the secret in AWS Secrets Manager
4. Update the actual secret value via AWS Console or CLI
5. Restart ECS service to pick up new secret: `terraform apply -target=module.ecs_service`

## Important Notes

- **Default Tags**: All resources automatically inherit tags from provider configuration (main.tf:4-9)
- **Log Retention**: CloudWatch logs are retained for 1 day (adjustable in modules/task-definition/main.tf:4)
- **Naming Convention**: Resources use `${project_name}-${environment}` prefix
- **Current Branch**: Working on `ambulensi-aws` branch (merge to `master` for production)
- **ECR Module**: Currently commented out in main.tf - using external ECR repository
- **Container Port**: Default is 3000 - ensure this matches your application
