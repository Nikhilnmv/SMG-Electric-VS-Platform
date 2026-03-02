# Debugging Guide
## VS Platform - Troubleshooting and Debugging

**Version:** 1.0.0  
**Date:** January 2025

---

## Overview

This guide helps developers debug issues in the VS Platform across all services.

## Common Issues

### Backend Issues

#### Service Not Starting

**Symptoms:** Backend fails to start

**Debug Steps:**
1. Check environment variables: `cat backend/.env`
2. Check database connection: `docker ps | grep postgres`
3. Check logs: `pnpm --filter backend dev` (look for errors)
4. Verify port is free: `lsof -i:3001`

#### API Errors

**Symptoms:** API returns errors

**Debug Steps:**
1. Check backend logs
2. Verify request format
3. Check authentication token
4. Review error handler output

### Frontend Issues

#### Build Errors

**Symptoms:** Frontend build fails

**Debug Steps:**
1. Clear Next.js cache: `rm -rf frontend/.next`
2. Reinstall dependencies: `pnpm install`
3. Check TypeScript errors: `pnpm --filter frontend type-check`
4. Review build logs

#### Runtime Errors

**Symptoms:** Frontend crashes or shows errors

**Debug Steps:**
1. Check browser console
2. Check network tab for API errors
3. Verify environment variables
4. Check authentication state

### Worker Issues

#### Jobs Not Processing

**Symptoms:** Videos stuck in "processing" status

**Debug Steps:**
1. Check worker logs: `pnpm --filter worker dev`
2. Verify Redis connection
3. Check queue status: `docker exec -it redis redis-cli KEYS bull:*`
4. Verify FFmpeg is installed
5. Check S3/local storage access

#### Transcoding Failures

**Symptoms:** Videos fail to transcode

**Debug Steps:**
1. Check worker logs for FFmpeg errors
2. Verify video file format
3. Check disk space: `df -h`
4. Review error messages in logs

### Database Issues

#### Connection Errors

**Symptoms:** Cannot connect to database

**Debug Steps:**
1. Check PostgreSQL is running: `docker ps | grep postgres`
2. Verify connection string in `.env`
3. Check database logs: `docker logs vs-platform-postgres`
4. Test connection: `psql $DATABASE_URL`

#### Migration Errors

**Symptoms:** Migrations fail

**Debug Steps:**
1. Check migration status: `pnpm --filter backend prisma migrate status`
2. Review migration files
3. Check database schema
4. Rollback if needed: `pnpm --filter backend prisma migrate resolve --rolled-back <migration>`

### Storage Issues

#### Upload Failures

**Symptoms:** Cannot upload videos

**Debug Steps:**
1. Check storage mode: `echo $STORAGE_MODE`
2. For S3: Verify AWS credentials
3. For local: Check directory permissions
4. Check file size limits
5. Review upload controller logs

#### File Not Found

**Symptoms:** Videos not loading

**Debug Steps:**
1. Check file exists in storage
2. Verify file paths
3. Check CDN configuration (if using S3)
4. Review access permissions

## Debugging Tools

### Logs

**Backend:**
```bash
pnpm --filter backend dev
# Or in production: kubectl logs deployment/backend
```

**Worker:**
```bash
pnpm --filter worker dev
# Or in production: kubectl logs deployment/worker
```

**Frontend:**
```bash
pnpm --filter frontend dev
# Check browser console
```

### Database Queries

**Connect to PostgreSQL:**
```bash
docker exec -it vs-platform-postgres psql -U postgres -d vs_platform
```

**Check Redis:**
```bash
docker exec -it vs-platform-redis redis-cli
```

### Network Debugging

**Check API:**
```bash
curl http://localhost:3001/health
curl http://localhost:3001/api/videos -H "Authorization: Bearer <token>"
```

**Check Frontend:**
```bash
curl http://localhost:3000
```

## Performance Debugging

### Slow Queries

1. Enable query logging in Prisma
2. Review slow query logs
3. Add database indexes
4. Optimize queries

### Memory Issues

1. Check memory usage: `docker stats`
2. Review application logs
3. Adjust container limits
4. Optimize code

## Best Practices

1. **Check Logs First**: Most issues are visible in logs
2. **Reproduce Locally**: Try to reproduce in local environment
3. **Isolate the Issue**: Determine which service is affected
4. **Check Dependencies**: Verify all services are running
5. **Review Recent Changes**: Check what changed recently

## Getting Help

1. Review documentation
2. Check existing issues
3. Review logs thoroughly
4. Document the issue
5. Contact support if needed

---

**Document Status:** Final  
**Last Updated:** January 2025
