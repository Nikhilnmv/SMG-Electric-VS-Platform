# Environment Switching Guide

This guide explains how to switch between **local development**, **staging cloud**, and **production cloud** environments using only `.env` files—no code changes required.

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Environment Configurations](#environment-configurations)
4. [Switching Between Environments](#switching-between-environments)
5. [Service-Specific Configuration](#service-specific-configuration)
6. [Architecture Diagrams](#architecture-diagrams)
7. [Troubleshooting](#troubleshooting)

## Overview

The VS Platform supports three environments:

- **Local Development**: Docker containers for databases, local filesystem storage, MailHog for email
- **Staging Cloud**: AWS RDS, ElastiCache, ClickHouse Cloud, S3, CloudFront, AWS SES
- **Production Cloud**: Same as staging but with production-grade resources and security

All switching happens via environment variables in `.env` files. The application automatically detects and configures itself based on these variables.

## Quick Start

### Local Development Setup

```bash
# Backend
cd backend
cp env.local.example .env

# Worker
cd ../worker
cp env.local.example .env

# Frontend
cd ../frontend
cp env.local.example .env.local
```

### Staging Cloud Setup

```bash
# Backend
cd backend
cp env.staging.example .env
# Edit .env and fill in your AWS/staging credentials

# Worker
cd ../worker
cp env.staging.example .env
# Edit .env and fill in your AWS/staging credentials

# Frontend
cd ../frontend
cp env.staging.example .env.local
# Edit .env.local and fill in your staging URLs
```

### Production Cloud Setup

```bash
# Backend
cd backend
cp env.production.example .env
# Edit .env and fill in your production AWS credentials
# IMPORTANT: Use secrets management (AWS Secrets Manager) in production!

# Worker
cd ../worker
cp env.production.example .env
# Edit .env and fill in your production AWS credentials

# Frontend
cd ../frontend
cp env.production.example .env.local
# Edit .env.local and fill in your production URLs
```

## Environment Configurations

### Local Development

| Service | Configuration |
|---------|--------------|
| **PostgreSQL** | Docker container: `localhost:5432` |
| **Redis** | Docker container: `localhost:6379` |
| **ClickHouse** | Docker container: `localhost:8123` |
| **Storage** | Local filesystem: `./uploads` |
| **CDN** | Not used (direct backend paths) |
| **SMTP** | MailHog: `localhost:1025` |
| **Worker** | Local processing with 2 concurrent jobs |

**Key Variables:**
```env
STORAGE_MODE=local
REDIS_HOST=localhost
CLICKHOUSE_HOST=localhost
SMTP_HOST=localhost
SMTP_PORT=1025
```

### Staging Cloud

| Service | Configuration |
|---------|--------------|
| **PostgreSQL** | AWS RDS endpoint |
| **Redis** | AWS ElastiCache endpoint |
| **ClickHouse** | ClickHouse Cloud (HTTPS) |
| **Storage** | AWS S3 bucket |
| **CDN** | CloudFront distribution |
| **SMTP** | AWS SES |
| **Worker** | Cloud worker with 4 concurrent jobs |

**Key Variables:**
```env
STORAGE_MODE=s3
REDIS_HOST=your-elasticache-endpoint.cache.amazonaws.com
CLICKHOUSE_HOST=your-clickhouse-host.clickhouse.cloud
CLICKHOUSE_PROTOCOL=https
AWS_S3_BUCKET=vs-platform-staging-uploads
CDN_URL=https://your-cloudfront-id.cloudfront.net
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
```

### Production Cloud

| Service | Configuration |
|---------|--------------|
| **PostgreSQL** | AWS RDS endpoint (production) |
| **Redis** | AWS ElastiCache endpoint (production) |
| **ClickHouse** | ClickHouse Cloud (HTTPS, production) |
| **Storage** | AWS S3 bucket (production) |
| **CDN** | CloudFront distribution (production) |
| **SMTP** | AWS SES (production) |
| **Worker** | Cloud worker with 8 concurrent jobs |

**Key Variables:**
```env
STORAGE_MODE=s3
REDIS_HOST=your-prod-elasticache-endpoint.cache.amazonaws.com
CLICKHOUSE_HOST=your-prod-clickhouse-host.clickhouse.cloud
AWS_S3_BUCKET=vs-platform-production-uploads
CDN_URL=https://your-prod-cloudfront-id.cloudfront.net
```

## Switching Between Environments

### Step-by-Step Process

1. **Stop all running services**
   ```bash
   # Stop Docker containers
   docker compose down
   
   # Stop backend, worker, frontend processes
   # (Ctrl+C in their terminals)
   ```

2. **Update environment files**
   ```bash
   # For local development
   cp backend/env.local.example backend/.env
   cp worker/env.local.example worker/.env
   cp frontend/env.local.example frontend/.env.local
   
   # For staging
   cp backend/env.staging.example backend/.env
   cp worker/env.staging.example worker/.env
   cp frontend/env.staging.example frontend/.env.local
   # Then edit and fill in credentials
   
   # For production
   cp backend/env.production.example backend/.env
   cp worker/env.production.example worker/.env
   cp frontend/env.production.example frontend/.env.local
   # Then edit and fill in credentials
   ```

3. **Start services**
   ```bash
   # For local: Start Docker services
   docker compose up -d postgres redis clickhouse
   
   # For cloud: Ensure cloud resources are running
   # (RDS, ElastiCache, ClickHouse Cloud, etc.)
   
   # Start application services
   pnpm --filter backend dev
   pnpm --filter worker dev
   pnpm --filter frontend dev
   ```

### Verification

After switching, verify the configuration:

```bash
# Check backend logs for storage mode
# Should show: "Storage mode: local" or "Storage mode: s3"

# Check ClickHouse connection
# Should show: "ClickHouse connection test successful"

# Check Redis connection
# Should show: "Redis connected"

# Test API endpoint
curl http://localhost:3001/health
```

## Service-Specific Configuration

### Database (PostgreSQL)

**Local:**
```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/vs_platform
```

**Staging/Production:**
```env
DATABASE_URL=postgresql://user:password@rds-endpoint.region.rds.amazonaws.com:5432/vs_platform
```

### Redis

**Local:**
```env
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
```

**Staging/Production:**
```env
REDIS_HOST=elasticache-endpoint.cache.amazonaws.com
REDIS_PORT=6379
REDIS_PASSWORD=your_redis_password
```

### ClickHouse

**Local:**
```env
CLICKHOUSE_HOST=localhost
CLICKHOUSE_PORT=8123
CLICKHOUSE_PROTOCOL=http
CLICKHOUSE_PASSWORD=
```

**Staging/Production:**
```env
CLICKHOUSE_HOST=your-host.clickhouse.cloud
CLICKHOUSE_PORT=8123
CLICKHOUSE_PROTOCOL=https
CLICKHOUSE_PASSWORD=your_password
```

### Storage

**Local:**
```env
STORAGE_MODE=local
UPLOADS_DIR=./uploads
```

**Staging/Production:**
```env
STORAGE_MODE=s3
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_S3_BUCKET=vs-platform-uploads
```

### CDN

**Local:**
```env
CDN_ENABLED=false
CDN_URL=
```

**Staging/Production:**
```env
CDN_ENABLED=true
CDN_URL=https://your-cloudfront-id.cloudfront.net
NEXT_PUBLIC_CLOUD_FRONT_URL=https://your-cloudfront-id.cloudfront.net
```

### SMTP

**Local (MailHog):**
```env
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USER=
SMTP_PASS=
SMTP_SECURE=false
```

**Staging/Production (AWS SES):**
```env
SMTP_HOST=email-smtp.us-east-1.amazonaws.com
SMTP_PORT=587
SMTP_USER=your_ses_username
SMTP_PASS=your_ses_password
SMTP_SECURE=true
```

## Architecture Diagrams

### Local Development Architecture

```
┌─────────────┐
│   Frontend  │ (localhost:3000)
│  Next.js    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Backend   │ (localhost:3001)
│   Express   │
└──────┬──────┘
       │
       ├──► PostgreSQL (Docker: localhost:5432)
       ├──► Redis (Docker: localhost:6379)
       ├──► ClickHouse (Docker: localhost:8123)
       └──► Local Filesystem (./uploads)
            │
            ▼
┌─────────────┐
│   Worker    │ (Local processing)
│  BullMQ     │
└─────────────┘
```

### Staging/Production Cloud Architecture

```
┌─────────────┐
│   Frontend  │ (CloudFront/CDN)
│  Next.js    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   Backend   │ (ECS/EKS)
│   Express   │
└──────┬──────┘
       │
       ├──► AWS RDS PostgreSQL
       ├──► AWS ElastiCache Redis
       ├──► ClickHouse Cloud (HTTPS)
       └──► AWS S3
            │
            ▼
       ┌─────────────┐
       │ CloudFront  │ (CDN)
       └─────────────┘
            │
            ▼
┌─────────────┐
│   Worker    │ (ECS/EKS)
│  BullMQ     │
└─────────────┘
```

### Storage Flow Comparison

**Local Mode:**
```
Upload → Backend → Local FS (./uploads/raw/)
                → Worker → Local FS (./uploads/hls/)
                → Frontend → Direct backend path (/uploads/hls/...)
```

**S3 Mode:**
```
Upload → Backend → S3 (raw/)
                → Worker → S3 (hls/)
                → CloudFront → Frontend (CDN URL)
```

## Troubleshooting

### Common Issues

#### 1. Storage Mode Mismatch

**Problem:** Backend uses S3 but worker uses local (or vice versa)

**Solution:** Ensure both `backend/.env` and `worker/.env` have the same `STORAGE_MODE`:
```env
# Both must match
STORAGE_MODE=s3  # or STORAGE_MODE=local
```

#### 2. ClickHouse Connection Failed

**Problem:** Cannot connect to ClickHouse Cloud

**Solution:** 
- Verify `CLICKHOUSE_PROTOCOL=https` for cloud
- Check `CLICKHOUSE_PASSWORD` is correct
- Ensure ClickHouse Cloud endpoint is accessible

#### 3. Redis Connection Failed

**Problem:** Cannot connect to ElastiCache

**Solution:**
- Verify `REDIS_HOST` is the correct ElastiCache endpoint
- Check `REDIS_PASSWORD` is set (ElastiCache requires password)
- Ensure security groups allow connection

#### 4. S3 Upload Fails

**Problem:** Cannot upload to S3

**Solution:**
- Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are correct
- Check `AWS_S3_BUCKET` exists and is accessible
- Ensure IAM permissions allow S3 access

#### 5. CDN Not Working

**Problem:** Videos not loading from CloudFront

**Solution:**
- Verify `CDN_URL` and `NEXT_PUBLIC_CLOUD_FRONT_URL` match
- Check CloudFront distribution is deployed and active
- Ensure S3 bucket has proper CORS configuration

#### 6. Email Not Sending

**Problem:** Password reset emails not received

**Solution:**
- **Local:** Ensure MailHog is running (`docker run -d -p 1025:1025 -p 8025:8025 mailhog/mailhog`)
- **Cloud:** Verify AWS SES credentials and domain verification
- Check `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS` are correct

### Environment Detection

The application automatically detects the environment based on:

1. **Storage Mode:** `STORAGE_MODE` variable
2. **Database:** `DATABASE_URL` or `DB_HOST`
3. **Redis:** `REDIS_HOST`
4. **ClickHouse:** `CLICKHOUSE_PROTOCOL` (http = local, https = cloud)

### Validation

The application validates environment variables on startup:

- **Backend:** Uses `envsafe` to validate all required variables
- **Worker:** Uses `envsafe` to validate worker-specific variables
- **Frontend:** Next.js validates `NEXT_PUBLIC_*` variables at build time

If validation fails, the application will not start and will show specific error messages.

## Best Practices

1. **Never commit `.env` files** to version control
2. **Use secrets management** in production (AWS Secrets Manager, etc.)
3. **Rotate credentials regularly**, especially in production
4. **Test environment switching** in staging before production
5. **Document environment-specific configurations** for your team
6. **Use different JWT secrets** for each environment
7. **Monitor logs** after switching environments to catch issues early

## Next Steps

- See [LOCAL_DEVELOPMENT_GUIDE.md](./LOCAL_DEVELOPMENT_GUIDE.md) for local setup details
- See [CLOUD_DEPLOYMENT_REFERENCE.md](./CLOUD_DEPLOYMENT_REFERENCE.md) for cloud deployment
- See [Testing Guide](./TESTING.md) for testing in different environments
