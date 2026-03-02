# Environment Management
## VS Platform - Environment Configuration Guide

**Version:** 1.0.0  
**Date:** January 2025

---

## Environment Overview

The VS Platform supports three environments:

1. **Local Development**: Docker containers, local storage
2. **Staging Cloud**: AWS cloud resources for testing
3. **Production Cloud**: AWS cloud resources for live system

## Environment Switching

All environment switching is done via `.env` files—no code changes required.

### Local Development

- Copy `env.local.example` to `.env`
- Uses Docker containers for databases
- Local filesystem storage
- MailHog for email

### Staging

- Copy `env.staging.example` to `.env`
- Fill in AWS credentials
- Uses cloud resources

### Production

- Copy `env.production.example` to `.env`
- Fill in production AWS credentials
- Use secrets management

## Configuration Files

### Backend

- `backend/env.local.example`
- `backend/env.staging.example`
- `backend/env.production.example`

### Worker

- `worker/env.local.example`
- `worker/env.staging.example`
- `worker/env.production.example`

### Frontend

- `frontend/env.local.example`
- `frontend/env.staging.example`
- `frontend/env.production.example`

## Key Configuration Variables

### Database

- `DATABASE_URL`: PostgreSQL connection string
- `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`

### Redis

- `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`

### Storage

- `STORAGE_MODE`: `local` or `s3`
- `AWS_REGION`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_BUCKET`

### CDN

- `CDN_URL`, `CLOUDFRONT_URL`

### SMTP

- `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`

## Best Practices

1. Never commit `.env` files
2. Use secrets management in production
3. Rotate credentials regularly
4. Test environment switching in staging

---

**Document Status:** Final  
**Last Updated:** January 2025
