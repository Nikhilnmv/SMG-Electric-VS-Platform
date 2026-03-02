# Deployment Guide
## VS Platform - Step-by-Step Deployment Instructions

**Version:** 1.0.0  
**Date:** January 2025

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Infrastructure Setup](#infrastructure-setup)
3. [Application Deployment](#application-deployment)
4. [Post-Deployment](#post-deployment)
5. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts & Tools

- AWS Account with appropriate permissions
- Terraform >= 1.0.0
- AWS CLI configured
- Docker (for local testing)
- kubectl (for Kubernetes deployment)
- Git

### AWS Permissions Required

- EC2 (for EKS/ECS)
- RDS (for PostgreSQL)
- ElastiCache (for Redis)
- S3 (for storage)
- CloudFront (for CDN)
- IAM (for roles and policies)
- VPC (for networking)
- Route53 (optional, for DNS)

---

## Infrastructure Setup

### Step 1: Configure Terraform Variables

1. Navigate to infrastructure directory:
   ```bash
   cd infra/terraform/prod
   ```

2. Copy example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` with your values:
   ```hcl
   aws_region = "us-east-1"
   environment = "production"
   project_name = "vs-platform"
   
   # Database
   db_instance_class = "db.t3.medium"
   db_username = "admin"
   db_password = "your-secure-password"
   
   # Redis
   redis_node_type = "cache.t3.medium"
   
   # S3
   s3_bucket_name = "vs-platform-production-uploads"
   
   # VPC
   subnet_ids = ["subnet-xxx", "subnet-yyy"]
   allowed_cidr_blocks = ["10.0.0.0/16"]
   ```

### Step 2: Initialize Terraform

```bash
cd infra/terraform/prod
terraform init
```

### Step 3: Review Terraform Plan

```bash
terraform plan
```

Review the plan to ensure all resources are correct.

### Step 4: Apply Infrastructure

```bash
terraform apply
```

This will create:
- VPC and networking
- RDS PostgreSQL instance
- ElastiCache Redis cluster
- S3 buckets
- CloudFront distribution
- IAM roles and policies
- EKS cluster (if using Kubernetes)

**Note:** This process may take 15-30 minutes.

### Step 5: Save Outputs

After deployment, save the outputs:

```bash
terraform output > terraform-outputs.txt
```

Important outputs:
- `rds_endpoint`: Database connection string
- `redis_endpoint`: Redis connection endpoint
- `s3_bucket_name`: S3 bucket name
- `cloudfront_domain_name`: CDN URL
- `eks_cluster_name`: Kubernetes cluster name (if applicable)

---

## Application Deployment

### Step 1: Configure Environment Variables

#### Backend Configuration

1. Copy production environment template:
   ```bash
   cd backend
   cp env.production.example .env
   ```

2. Edit `.env` with your values:
   ```env
   NODE_ENV=production
   ENVIRONMENT=production
   
   DATABASE_URL=postgresql://admin:password@rds-endpoint:5432/vs_platform
   
   REDIS_HOST=your-elasticache-endpoint.cache.amazonaws.com
   REDIS_PORT=6379
   REDIS_PASSWORD=your-redis-password
   
   CLICKHOUSE_HOST=your-clickhouse-host.clickhouse.cloud
   CLICKHOUSE_PROTOCOL=https
   CLICKHOUSE_PASSWORD=your-clickhouse-password
   
   STORAGE_MODE=s3
   AWS_REGION=us-east-1
   AWS_ACCESS_KEY_ID=your-access-key
   AWS_SECRET_ACCESS_KEY=your-secret-key
   AWS_S3_BUCKET=vs-platform-production-uploads
   
   CDN_URL=https://your-cloudfront-id.cloudfront.net
   CLOUDFRONT_URL=https://your-cloudfront-id.cloudfront.net
   
   SMTP_HOST=email-smtp.us-east-1.amazonaws.com
   SMTP_USER=your-ses-username
   SMTP_PASS=your-ses-password
   
   JWT_SECRET=your-very-strong-secret-here
   FRONTEND_URL=https://yourdomain.com
   ```

#### Worker Configuration

1. Copy production environment template:
   ```bash
   cd worker
   cp env.production.example .env
   ```

2. Edit `.env` with same database/Redis/S3 credentials as backend.

#### Frontend Configuration

1. Copy production environment template:
   ```bash
   cd frontend
   cp env.production.example .env.local
   ```

2. Edit `.env.local`:
   ```env
   NEXT_PUBLIC_API_URL=https://api.yourdomain.com
   NEXT_PUBLIC_STORAGE_MODE=s3
   NEXT_PUBLIC_CLOUD_FRONT_URL=https://your-cloudfront-id.cloudfront.net
   ```

### Step 2: Build Docker Images

```bash
# Build backend
docker build -t vs-platform-backend:latest -f backend/Dockerfile .

# Build worker
docker build -t vs-platform-worker:latest -f worker/Dockerfile .

# Build frontend
docker build -t vs-platform-frontend:latest -f frontend/Dockerfile .
```

### Step 3: Push to Container Registry

```bash
# Tag images
docker tag vs-platform-backend:latest your-registry/vs-platform-backend:latest
docker tag vs-platform-worker:latest your-registry/vs-platform-worker:latest
docker tag vs-platform-frontend:latest your-registry/vs-platform-frontend:latest

# Push images
docker push your-registry/vs-platform-backend:latest
docker push your-registry/vs-platform-worker:latest
docker push your-registry/vs-platform-frontend:latest
```

### Step 4: Deploy to Kubernetes (EKS)

1. Configure kubectl:
   ```bash
   aws eks update-kubeconfig --name your-cluster-name --region us-east-1
   ```

2. Create Kubernetes secrets:
   ```bash
   kubectl create secret generic vs-platform-secrets \
     --from-env-file=backend/.env
   ```

3. Deploy services:
   ```bash
   # Apply Kubernetes manifests
   kubectl apply -f k8s/backend-deployment.yaml
   kubectl apply -f k8s/worker-deployment.yaml
   kubectl apply -f k8s/frontend-deployment.yaml
   ```

### Step 5: Run Database Migrations

```bash
# Connect to backend pod
kubectl exec -it backend-pod-name -- bash

# Run migrations
cd /app/backend
pnpm prisma migrate deploy
```

### Step 6: Create Initial Admin User

```bash
# Connect to backend pod
kubectl exec -it backend-pod-name -- bash

# Run admin creation script
./scripts/create-admin-user.sh admin@yourcompany.com SecurePassword123
```

---

## Post-Deployment

### Step 1: Verify Services

1. **Check Backend Health:**
   ```bash
   curl https://api.yourdomain.com/health
   ```

2. **Check Frontend:**
   ```bash
   curl https://yourdomain.com
   ```

3. **Check Worker:**
   ```bash
   kubectl logs -f worker-pod-name
   ```

### Step 2: Configure DNS

1. Point your domain to CloudFront distribution
2. Point API subdomain to load balancer
3. Update SSL certificates if needed

### Step 3: Set Up Monitoring

1. Configure CloudWatch alarms
2. Set up application logging
3. Configure error tracking
4. Set up performance monitoring

### Step 4: Configure Backups

1. Enable RDS automated backups
2. Configure S3 versioning
3. Set up backup retention policies

---

## Troubleshooting

### Common Issues

#### Database Connection Failed

**Problem:** Cannot connect to RDS

**Solution:**
- Check security groups allow connections from EKS/ECS
- Verify database endpoint is correct
- Check database credentials

#### Redis Connection Failed

**Problem:** Cannot connect to ElastiCache

**Solution:**
- Check security groups
- Verify Redis endpoint
- Check password configuration

#### S3 Upload Fails

**Problem:** Cannot upload to S3

**Solution:**
- Verify IAM roles have S3 permissions
- Check bucket name is correct
- Verify AWS credentials

#### CloudFront Not Serving Content

**Problem:** Videos not loading from CDN

**Solution:**
- Check CloudFront distribution is deployed
- Verify origin (S3) is accessible
- Check CORS configuration on S3
- Wait for CloudFront propagation (15-20 minutes)

#### Worker Not Processing Jobs

**Problem:** Videos stuck in processing

**Solution:**
- Check worker logs: `kubectl logs worker-pod`
- Verify Redis connection
- Check FFmpeg is installed in worker container
- Verify S3 access from worker

---

## Rollback Procedure

If deployment fails:

1. **Rollback Kubernetes Deployments:**
   ```bash
   kubectl rollout undo deployment/backend
   kubectl rollout undo deployment/worker
   kubectl rollout undo deployment/frontend
   ```

2. **Rollback Database Migrations:**
   ```bash
   # Connect to backend pod
   kubectl exec -it backend-pod -- bash
   cd /app/backend
   pnpm prisma migrate resolve --rolled-back <migration-name>
   ```

3. **Restore Infrastructure:**
   ```bash
   cd infra/terraform/prod
   terraform destroy  # Only if necessary
   ```

---

## Next Steps

After successful deployment:

1. Review [Operations_Runbook.md](./Operations_Runbook.md) for day-to-day operations
2. Review [Security_Compliance.md](./Security_Compliance.md) for security best practices
3. Set up monitoring and alerts
4. Train your team on system operation

---

**Document Status:** Final  
**Last Updated:** January 2025
