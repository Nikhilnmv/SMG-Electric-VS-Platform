# Operations Runbook
## VS Platform - Day-to-Day Operations Guide

**Version:** 1.0.0  
**Date:** January 2025

---

## Table of Contents

1. [Daily Operations](#daily-operations)
2. [Monitoring](#monitoring)
3. [Common Tasks](#common-tasks)
4. [Troubleshooting](#troubleshooting)
5. [Maintenance](#maintenance)
6. [Emergency Procedures](#emergency-procedures)

---

## Daily Operations

### Health Checks

**Morning Routine:**
1. Check application health endpoints
2. Review error logs
3. Check queue depth (Redis)
4. Verify database connections
5. Check CDN status

**Commands:**
```bash
# Backend health
curl https://api.yourdomain.com/health

# Readiness check
curl https://api.yourdomain.com/ready

# Check worker status
kubectl logs -f deployment/worker --tail=50
```

### Monitoring Dashboard

Access monitoring dashboards:
- **Application Metrics**: CloudWatch or Prometheus
- **Database**: RDS Performance Insights
- **CDN**: CloudFront Reports
- **Error Tracking**: Application logs

---

## Common Tasks

### User Management

**Create New User:**
```bash
kubectl exec -it backend-pod -- ./scripts/create-admin-user.sh user@example.com Password123
```

**Reset User Password:**
- Use admin panel: Admin → Users → Reset Password
- Or use password reset email flow

**Update User Role:**
- Admin panel: Admin → Users → Edit → Change Role

### Content Management

**Upload Video:**
1. Log in as admin/editor
2. Navigate to "Upload Video"
3. Select video file
4. Fill in metadata
5. Submit

**Monitor Processing:**
- Check worker logs for transcoding status
- Admin panel shows video status

**Delete Video:**
- Admin panel: Videos → Delete
- Removes video, HLS files, and thumbnails

### Database Operations

**Backup:**
- RDS automated backups (daily)
- Manual snapshot: AWS Console → RDS → Snapshots → Create

**Restore:**
- AWS Console → RDS → Snapshots → Restore

**Run Migrations:**
```bash
kubectl exec -it backend-pod -- pnpm --filter backend prisma migrate deploy
```

### Queue Management

**Check Queue Status:**
```bash
# Connect to Redis
kubectl exec -it redis-pod -- redis-cli

# List queues
KEYS bull:*

# Check job count
LLEN bull:video-processing:wait
```

**Retry Failed Jobs:**
- Check dead-letter queue
- Manually retry via admin panel or worker logs

---

## Troubleshooting

### Service Not Responding

1. **Check Pod Status:**
   ```bash
   kubectl get pods
   kubectl describe pod <pod-name>
   ```

2. **Check Logs:**
   ```bash
   kubectl logs <pod-name> --tail=100
   ```

3. **Restart Service:**
   ```bash
   kubectl rollout restart deployment/backend
   ```

### Database Issues

**Connection Errors:**
- Check RDS status in AWS Console
- Verify security groups
- Check connection string

**Performance Issues:**
- Check RDS Performance Insights
- Review slow query logs
- Optimize indexes if needed

### Video Processing Issues

**Videos Stuck in Processing:**
1. Check worker logs
2. Verify Redis connection
3. Check FFmpeg availability
4. Verify S3 access
5. Restart worker if needed

**Transcoding Failures:**
- Check worker logs for FFmpeg errors
- Verify video file format
- Check disk space
- Review error messages

### CDN Issues

**Content Not Loading:**
- Check CloudFront distribution status
- Verify S3 bucket permissions
- Check CORS configuration
- Wait for propagation (15-20 min)

---

## Maintenance

### Regular Maintenance Tasks

**Weekly:**
- Review error logs
- Check disk usage
- Review performance metrics
- Update dependencies (test first)

**Monthly:**
- Review security patches
- Optimize database
- Review and clean up old data
- Review costs

**Quarterly:**
- Security audit
- Performance review
- Capacity planning
- Disaster recovery test

### Updates & Upgrades

**Application Updates:**
1. Test in staging
2. Create backup
3. Deploy to production
4. Monitor for issues
5. Rollback if needed

**Database Migrations:**
1. Test migration in staging
2. Backup production database
3. Run migration during maintenance window
4. Verify data integrity
5. Monitor performance

---

## Emergency Procedures

### Service Outage

1. **Identify Affected Service:**
   - Check health endpoints
   - Review logs
   - Check monitoring alerts

2. **Quick Fixes:**
   - Restart service: `kubectl rollout restart deployment/<service>`
   - Scale up: `kubectl scale deployment/<service> --replicas=3`

3. **If Quick Fix Fails:**
   - Rollback to previous version
   - Check infrastructure status
   - Contact support team

### Data Loss

1. **Stop Further Damage:**
   - Stop affected services if needed
   - Isolate affected systems

2. **Recovery:**
   - Restore from backup
   - Verify data integrity
   - Resume services

### Security Incident

1. **Immediate Actions:**
   - Isolate affected systems
   - Change compromised credentials
   - Review access logs

2. **Investigation:**
   - Review security logs
   - Identify attack vector
   - Assess damage

3. **Remediation:**
   - Patch vulnerabilities
   - Update security policies
   - Notify stakeholders

---

## Monitoring & Alerts

### Key Metrics to Monitor

- **Application:**
  - Response time
  - Error rate
  - Request rate
  - Queue depth

- **Infrastructure:**
  - CPU usage
  - Memory usage
  - Disk usage
  - Network traffic

- **Database:**
  - Connection count
  - Query performance
  - Storage usage
  - Backup status

### Alert Thresholds

Configure alerts for:
- Error rate > 1%
- Response time > 2s
- Queue depth > 100
- CPU usage > 80%
- Memory usage > 85%
- Disk usage > 90%

---

## Support Contacts

- **Technical Issues**: Review logs and documentation first
- **Infrastructure**: AWS Support
- **Database**: RDS Support
- **Emergency**: Contact on-call engineer

---

**Document Status:** Final  
**Last Updated:** January 2025
