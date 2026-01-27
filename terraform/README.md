# ECS Pratice Terraform Deployment

This directory contains Terraform modules for deploying the Flask app to AWS ECS with load balancing.

## Structure

```
terraform/
├── main.tf                      # Main configuration file
├── variables.tf                 # Input variables
├── outputs.tf                   # Output values
├── terraform.tfvars.example     # Example variables file
└── modules/
    ├── vpc/                     # VPC, subnets, security groups
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── iam/                     # IAM roles and policies
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── alb/                     # Application Load Balancer
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecs/                     # ECS cluster, service, tasks
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

## Prerequisites

1. **AWS Account** - with appropriate permissions
2. **Terraform** - version >= 1.0
3. **AWS CLI** - configured with credentials
4. **Docker Image** - Push your Flask app to ECR:

```bash
# Build and push Docker image to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

docker build -t ecs-pratice .
docker tag ecs-pratice:latest YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/ecs-pratice:latest
docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/ecs-pratice:latest
```

5. **S3 Backend** - Create for remote state:

```bash
aws s3 mb s3://ecs-pratice-terraform-state --region us-east-1
aws dynamodb create-table \
  --table-name terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

## Setup

1. **Copy example variables**:
```bash
cp terraform.tfvars.example terraform.tfvars
```

2. **Edit terraform.tfvars** with your values:
   - Update `environment` (e.g., "prod", "dev")
   - Update `container_image` with your ECR image URI
   - Adjust VPC CIDR and subnet ranges if needed
   - Configure CPU, memory, and scaling options

3. **Initialize Terraform**:
```bash
terraform init
```

4. **Plan deployment**:
```bash
terraform plan -out=tfplan
```

5. **Apply configuration**:
```bash
terraform apply tfplan
```

## Outputs

After successful deployment, Terraform will output:
- `alb_dns_name` - Load balancer DNS (access your app here)
- `ecs_cluster_name` - ECS cluster name
- `ecs_service_name` - ECS service name
- `cloudwatch_log_group` - CloudWatch logs location

## Accessing Your App

Once deployed, access your Flask app at:
```
http://<alb_dns_name>
```

View logs:
```bash
aws logs tail /ecs/prod-app --follow
```

## Modules

### VPC Module
- Creates VPC with public and private subnets across 2 AZs
- NAT gateways for private subnet internet access
- Security groups for ALB and ECS tasks

### IAM Module
- ECS task execution role (for pulling images, logs)
- ECS task role (for application permissions)
- CloudWatch logs policy

### ALB Module
- Application Load Balancer
- Target group for ECS tasks
- HTTP listener on port 80

### ECS Module
- ECS cluster with Container Insights
- Fargate task definition
- ECS service with desired count
- Auto-scaling (CPU and memory based)
- CloudWatch log group

## Scaling

The ECS service includes auto-scaling policies:
- **CPU**: Scales when average CPU > 70%
- **Memory**: Scales when average memory > 80%
- Min: desired_count, Max: max_capacity

## Cleanup

Destroy all resources:
```bash
terraform destroy
```

Confirm deletion when prompted.

## Troubleshooting

Check task status:
```bash
aws ecs describe-services --cluster prod-cluster --services prod-service --region us-east-1
```

View task logs:
```bash
aws logs tail /ecs/prod-app --follow
```

List ECS tasks:
```bash
aws ecs list-tasks --cluster prod-cluster --region us-east-1
```

## Notes

- State is stored in S3 with encryption enabled
- Default region is us-east-1 (update as needed)
- Fargate launch type used (no EC2 instances to manage)
- Tasks use IAM roles for secure AWS API access
- CloudWatch Container Insights enabled for monitoring
