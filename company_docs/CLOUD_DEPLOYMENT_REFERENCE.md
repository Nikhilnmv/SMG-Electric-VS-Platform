# Cloud Deployment Reference
## VS Platform - Cloud Deployment Guide

**Version:** 1.0.0  
**Date:** January 2025

---

## Overview

This guide provides detailed instructions for deploying the VS Platform to cloud environments (staging and production) on AWS.

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0.0
- AWS CLI configured
- kubectl (for Kubernetes)
- Docker

## Infrastructure Deployment

### Step 1: Configure Terraform

1. Navigate to infrastructure directory:
   ```bash
   cd infra/terraform/prod  # or staging
   ```

2. Copy and configure variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Review plan:
   ```bash
   terraform plan
   ```

5. Apply infrastructure:
   ```bash
   terraform apply
   ```

### Step 2: Configure Application

1. Set environment variables (see [ENVIRONMENT_SWITCHING.md](./ENVIRONMENT_SWITCHING.md))
2. Build Docker images
3. Push to container registry
4. Deploy to Kubernetes/ECS

## AWS Services Used

- **RDS PostgreSQL**: Primary database
- **ElastiCache Redis**: Job queue and caching
- **S3**: Video storage
- **CloudFront**: CDN for content delivery
- **EKS/ECS**: Container orchestration
- **SES**: Email delivery
- **IAM**: Access control

## Deployment Checklist

- [ ] Infrastructure deployed via Terraform
- [ ] Environment variables configured
- [ ] Docker images built and pushed
- [ ] Kubernetes/ECS services deployed
- [ ] Database migrations run
- [ ] Health checks passing
- [ ] Monitoring configured
- [ ] Backups enabled

## Troubleshooting

See [Operations_Runbook.md](../company_docs/Operations_Runbook.md) for troubleshooting guidance.

---

**Document Status:** Final  
**Last Updated:** January 2025
