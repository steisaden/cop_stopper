#!/bin/bash

# Cop Stopper Production Deployment Script
set -e

echo "🚀 Starting Cop Stopper deployment..."

# Configuration
ENVIRONMENT=${1:-production}
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="./logs/deploy_$(date +%Y%m%d_%H%M%S).log"

# Create necessary directories
mkdir -p logs backups uploads nginx/ssl

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to check if service is healthy
check_health() {
    local service=$1
    local max_attempts=30
    local attempt=1

    log "Checking health of $service..."
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose -f docker-compose.prod.yml exec -T "$service" curl -f http://localhost:3000/health > /dev/null 2>&1; then
            log "$service is healthy"
            return 0
        fi
        
        log "Attempt $attempt/$max_attempts: $service not ready yet..."
        sleep 10
        ((attempt++))
    done
    
    log "ERROR: $service failed health check after $max_attempts attempts"
    return 1
}

# Function to backup database
backup_database() {
    if docker-compose -f docker-compose.prod.yml ps postgres | grep -q "Up"; then
        log "Creating database backup..."
        mkdir -p "$BACKUP_DIR"
        
        docker-compose -f docker-compose.prod.yml exec -T postgres pg_dump \
            -U cop_stopper_user \
            -d cop_stopper_prod \
            --no-password > "$BACKUP_DIR/database_backup.sql"
        
        log "Database backup created: $BACKUP_DIR/database_backup.sql"
    else
        log "No existing database to backup"
    fi
}

# Function to restore database from backup
restore_database() {
    local backup_file=$1
    if [ -f "$backup_file" ]; then
        log "Restoring database from $backup_file..."
        
        docker-compose -f docker-compose.prod.yml exec -T postgres psql \
            -U cop_stopper_user \
            -d cop_stopper_prod \
            --no-password < "$backup_file"
        
        log "Database restored successfully"
    else
        log "Backup file not found: $backup_file"
        return 1
    fi
}

# Function to rollback deployment
rollback() {
    log "🔄 Rolling back deployment..."
    
    # Stop current containers
    docker-compose -f docker-compose.prod.yml down
    
    # Restore from latest backup
    local latest_backup=$(ls -t backups/*/database_backup.sql 2>/dev/null | head -n1)
    if [ -n "$latest_backup" ]; then
        restore_database "$latest_backup"
    fi
    
    # Start previous version (this would need version tagging in real deployment)
    docker-compose -f docker-compose.prod.yml up -d
    
    log "Rollback completed"
}

# Main deployment process
main() {
    log "Starting deployment for environment: $ENVIRONMENT"
    
    # Check if .env file exists
    if [ ! -f "backend/.env.production" ]; then
        log "ERROR: backend/.env.production file not found"
        log "Please copy backend/.env.production.example and configure it"
        exit 1
    fi
    
    # Load environment variables
    export $(grep -v '^#' backend/.env.production | xargs)
    
    # Validate required environment variables
    required_vars=("DB_PASSWORD" "JWT_SECRET")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log "ERROR: Required environment variable $var is not set"
            exit 1
        fi
    done
    
    # Create backup of existing deployment
    backup_database
    
    # Pull latest images
    log "Pulling latest Docker images..."
    docker-compose -f docker-compose.prod.yml pull
    
    # Build application images
    log "Building application images..."
    docker-compose -f docker-compose.prod.yml build --no-cache
    
    # Stop existing containers
    log "Stopping existing containers..."
    docker-compose -f docker-compose.prod.yml down
    
    # Start database first
    log "Starting database..."
    docker-compose -f docker-compose.prod.yml up -d postgres redis
    
    # Wait for database to be ready
    log "Waiting for database to be ready..."
    sleep 30
    
    # Start backend services
    log "Starting backend services..."
    docker-compose -f docker-compose.prod.yml up -d backend
    
    # Wait for backend to be healthy
    if ! check_health backend; then
        log "ERROR: Backend failed to start properly"
        rollback
        exit 1
    fi
    
    # Start remaining services
    log "Starting remaining services..."
    docker-compose -f docker-compose.prod.yml up -d
    
    # Final health check
    sleep 10
    if ! check_health backend; then
        log "ERROR: Final health check failed"
        rollback
        exit 1
    fi
    
    # Clean up old images
    log "Cleaning up old Docker images..."
    docker image prune -f
    
    log "✅ Deployment completed successfully!"
    log "🌐 Application is available at: https://your-domain.com"
    log "📊 Health check: https://your-domain.com/health"
    log "📝 Logs: docker-compose -f docker-compose.prod.yml logs -f"
}

# Handle script interruption
trap 'log "Deployment interrupted"; exit 1' INT TERM

# Run main deployment
main "$@"