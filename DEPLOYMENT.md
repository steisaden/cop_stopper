# Cop Stopper Deployment Guide

This guide covers deploying the Cop Stopper application to production environments.

## Prerequisites

- Docker and Docker Compose
- SSL certificates for HTTPS
- Domain name configured
- Environment variables configured
- Database backup strategy

## Backend Deployment

### 1. Environment Setup

Copy the environment template and configure production values:

```bash
cd backend
cp .env.example .env
```

Configure the following critical environment variables:

```bash
# Security - MUST be changed for production
JWT_SECRET=your-super-secure-jwt-secret-minimum-32-characters
ENCRYPTION_KEY=your-32-character-encryption-key-here

# Database
DATABASE_URL=postgresql://username:password@host:5432/database
REDIS_URL=redis://username:password@host:6379

# External APIs
OPENAI_API_KEY=your-openai-api-key

# File Storage
AWS_ACCESS_KEY_ID=your-aws-access-key
AWS_SECRET_ACCESS_KEY=your-aws-secret-key
S3_BUCKET_NAME=cop-stopper-production-files

# Domain and CORS
ALLOWED_ORIGINS=https://yourdomain.com,https://app.yourdomain.com
```

### 2. SSL Certificate Setup

Place your SSL certificates in the `backend/ssl/` directory:

```bash
mkdir -p backend/ssl
# Copy your certificates
cp /path/to/cert.pem backend/ssl/cert.pem
cp /path/to/key.pem backend/ssl/key.pem
```

### 3. Database Migration

Initialize the production database:

```bash
# Start only the database
docker-compose -f docker-compose.prod.yml up -d postgres

# Wait for database to be ready
sleep 30

# Run migrations (database will auto-initialize from init.sql)
docker-compose -f docker-compose.prod.yml logs postgres
```

### 4. Production Deployment

Deploy the full stack:

```bash
# Build and start all services
docker-compose -f docker-compose.prod.yml up -d

# Check service health
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs
```

### 5. Health Checks

Verify all services are running:

```bash
# Backend health
curl https://yourdomain.com/health

# Database connection
docker-compose -f docker-compose.prod.yml exec postgres pg_isready

# Redis connection
docker-compose -f docker-compose.prod.yml exec redis redis-cli ping
```

## Mobile App Deployment

### 1. Backend Configuration

Update the API base URL in the mobile app:

```dart
// mobile/lib/src/services/api_service.dart
static const String baseUrl = 'https://yourdomain.com/api';
```

### 2. Android Deployment

#### Build Release APK

```bash
cd mobile
flutter build apk --release
```

#### Build App Bundle for Play Store

```bash
flutter build appbundle --release
```

#### Upload to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app or select existing app
3. Upload the app bundle from `build/app/outputs/bundle/release/app-release.aab`
4. Fill in store listing information
5. Set up content rating and pricing
6. Submit for review

### 3. iOS Deployment

#### Build for iOS

```bash
cd mobile
flutter build ios --release
```

#### Archive and Upload

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Product → Archive
4. Upload to App Store Connect
5. Submit for App Store review

## Security Considerations

### 1. Environment Variables

Never commit sensitive environment variables to version control:

```bash
# Add to .gitignore
.env
.env.production
.env.local
```

### 2. Database Security

- Use strong passwords
- Enable SSL connections
- Restrict network access
- Regular security updates
- Automated backups

### 3. API Security

- Rate limiting configured
- HTTPS only
- CORS properly configured
- Input validation
- SQL injection protection
- XSS protection

### 4. File Storage Security

- Encrypted at rest
- Secure access keys
- Proper IAM policies
- Regular key rotation

## Monitoring and Logging

### 1. Application Monitoring

Set up monitoring for:

- API response times
- Error rates
- Database performance
- File upload success rates
- User authentication metrics

### 2. Log Management

Configure centralized logging:

```bash
# Example with ELK stack
docker-compose -f docker-compose.monitoring.yml up -d
```

### 3. Alerts

Set up alerts for:

- High error rates
- Database connection failures
- Disk space issues
- SSL certificate expiration
- Unusual traffic patterns

## Backup Strategy

### 1. Database Backups

Automated daily backups:

```bash
# Create backup script
#!/bin/bash
BACKUP_DIR="/backups/$(date +%Y-%m-%d)"
mkdir -p $BACKUP_DIR

docker-compose exec postgres pg_dump -U cop_stopper_user cop_stopper > $BACKUP_DIR/database.sql

# Upload to secure storage
aws s3 cp $BACKUP_DIR/database.sql s3://cop-stopper-backups/database/$(date +%Y-%m-%d).sql
```

### 2. File Storage Backups

- Configure S3 versioning
- Cross-region replication
- Lifecycle policies for old files

### 3. Configuration Backups

- Environment variables
- SSL certificates
- Docker configurations
- Nginx configurations

## Scaling Considerations

### 1. Horizontal Scaling

For high traffic, consider:

- Multiple backend instances
- Load balancer (nginx, HAProxy)
- Database read replicas
- Redis clustering
- CDN for static assets

### 2. Vertical Scaling

Monitor and adjust:

- CPU and memory limits
- Database connection pools
- File upload limits
- Rate limiting thresholds

## Maintenance

### 1. Regular Updates

- Security patches
- Dependency updates
- SSL certificate renewal
- Database maintenance

### 2. Performance Optimization

- Database query optimization
- API response caching
- Image compression
- CDN configuration

### 3. Disaster Recovery

- Backup restoration procedures
- Failover processes
- Communication plans
- Recovery time objectives

## Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
   ```bash
   # Check certificate validity
   openssl x509 -in ssl/cert.pem -text -noout
   ```

2. **Database Connection Issues**
   ```bash
   # Check database logs
   docker-compose logs postgres
   ```

3. **High Memory Usage**
   ```bash
   # Monitor container resources
   docker stats
   ```

4. **API Rate Limiting**
   ```bash
   # Check nginx logs
   docker-compose logs nginx
   ```

### Performance Monitoring

```bash
# Monitor API performance
curl -w "@curl-format.txt" -o /dev/null -s https://yourdomain.com/health

# Database performance
docker-compose exec postgres psql -U cop_stopper_user -d cop_stopper -c "SELECT * FROM pg_stat_activity;"
```

## Support and Maintenance

- Monitor error logs daily
- Review security alerts weekly
- Update dependencies monthly
- Full security audit quarterly
- Disaster recovery testing annually

For additional support, refer to the project documentation or contact the development team.