#!/bin/bash

# Bank Portal - Docker-basiertes Database Backup System
# Uses docker-compose exec to backup databases from within containers

set -e

# Configuration
BACKUP_DIR="/tmp/bankportal-backup"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="/tmp/bankportal-backup.log"

# Database Configuration (verwendet Docker-Container)
AUTH_DB_USER="admin"
AUTH_DB_NAME="authdb"
AUTH_CONTAINER="postgres-auth"

ACCOUNT_DB_USER="admin"
ACCOUNT_DB_NAME="accountdb"
ACCOUNT_CONTAINER="postgres-account"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# Create backup directory
create_backup_dir() {
    log "Creating backup directory structure..."
    mkdir -p "$BACKUP_DIR/auth-service/$TIMESTAMP"
    mkdir -p "$BACKUP_DIR/account-service/$TIMESTAMP"
    mkdir -p "$BACKUP_DIR/full-backup/$TIMESTAMP"
    success "Backup directories created at $BACKUP_DIR"
}

# Check if services are running
check_services() {
    log "Checking if Docker services are running..."
    
    if ! docker-compose ps | grep -q "Up"; then
        error "Docker services are not running!"
        log "Please start services first:"
        log "  docker-compose up -d"
        return 1
    fi
    
    success "Docker services are running"
    return 0
}

# Check database connectivity using docker exec
check_db_connection() {
    local container=$1
    local user=$2
    local db=$3
    local service_name=$4
    
    log "Checking connection to $service_name database in container $container..."
    
    if docker-compose exec -T "$container" psql -U "$user" -d "$db" -c "\l" > /dev/null 2>&1; then
        success "$service_name database is accessible"
        return 0
    else
        error "$service_name database is not accessible"
        return 1
    fi
}

# Backup database using docker exec
backup_database() {
    local container=$1
    local user=$2
    local db=$3
    local service_name=$4
    local backup_path=$5
    
    log "Starting backup for $service_name database from container $container..."
    
    # Create temporary backup inside container, then copy out
    local temp_backup="/tmp/${service_name}_backup_${TIMESTAMP}"
    
    # Full database dump (custom format)
    log "Creating custom format backup for $service_name..."
    if docker-compose exec -T "$container" pg_dump -U "$user" -d "$db" \
        --verbose --clean --if-exists --create \
        --format=custom --compress=9 \
        --file="$temp_backup.backup" 2>> "$LOG_FILE"; then
        
        # Copy backup out of container
        docker cp "$container:$temp_backup.backup" "$backup_path/${service_name}_full_${TIMESTAMP}.backup"
        success "$service_name custom backup completed"
    else
        error "Failed to create custom backup for $service_name"
        log "Trying alternative backup method for $service_name..."
        
        # Fallback: Try without compression
        if docker-compose exec -T "$container" pg_dump -U "$user" -d "$db" \
            --verbose --clean --if-exists --create \
            --format=custom \
            --file="$temp_backup.backup" 2>> "$LOG_FILE"; then
            
            docker cp "$container:$temp_backup.backup" "$backup_path/${service_name}_full_${TIMESTAMP}.backup"
            success "$service_name custom backup completed (without compression)"
        else
            warning "Custom format backup failed for $service_name, continuing with SQL only"
        fi
    fi
    
    # Plain SQL dump
    log "Creating plain SQL dump for $service_name..."
    if docker-compose exec -T "$container" pg_dump -U "$user" -d "$db" \
        --verbose --clean --if-exists --create \
        --format=plain \
        --file="$temp_backup.sql" 2>> "$LOG_FILE"; then
        
        # Copy SQL dump out of container
        docker cp "$container:$temp_backup.sql" "$backup_path/${service_name}_full_${TIMESTAMP}.sql"
        success "$service_name SQL dump completed"
    else
        warning "Failed to create SQL dump for $service_name"
    fi
    
    # Schema-only backup
    log "Creating schema backup for $service_name..."
    if docker-compose exec -T "$container" pg_dump -U "$user" -d "$db" \
        --schema-only --verbose \
        --file="$temp_backup.schema.sql" 2>> "$LOG_FILE"; then
        
        docker cp "$container:$temp_backup.schema.sql" "$backup_path/${service_name}_schema_${TIMESTAMP}.sql"
        success "$service_name schema backup completed"
    else
        warning "Failed to create schema backup for $service_name"
    fi
    
    # Data-only backup
    log "Creating data backup for $service_name..."
    if docker-compose exec -T "$container" pg_dump -U "$user" -d "$db" \
        --data-only --verbose \
        --file="$temp_backup.data.sql" 2>> "$LOG_FILE"; then
        
        docker cp "$container:$temp_backup.data.sql" "$backup_path/${service_name}_data_${TIMESTAMP}.sql"
        success "$service_name data backup completed"
    else
        warning "Failed to create data backup for $service_name"
    fi
    
    # Cleanup temporary files in container
    docker-compose exec -T "$container" rm -f "$temp_backup"* 2>/dev/null || true
    
    # Compress backups
    log "Compressing $service_name backups..."
    cd "$backup_path"
    tar -czf "${service_name}_backup_${TIMESTAMP}.tar.gz" *.sql *.backup 2>> "$LOG_FILE"
    
    # Calculate backup size
    local backup_size=$(du -sh "${service_name}_backup_${TIMESTAMP}.tar.gz" | cut -f1)
    success "$service_name backup compressed: ${backup_size}"
    
    return 0
}

# Create backup manifest
create_manifest() {
    local manifest_file="$BACKUP_DIR/full-backup/$TIMESTAMP/backup_manifest.json"
    
    log "Creating backup manifest..."
    
    cat > "$manifest_file" << EOF
{
    "backup_info": {
        "timestamp": "$TIMESTAMP",
        "date": "$(date -Iseconds)",
        "version": "1.0",
        "type": "docker_backup",
        "method": "docker-compose exec pg_dump"
    },
    "databases": {
        "auth_service": {
            "container": "$AUTH_CONTAINER",
            "database": "$AUTH_DB_NAME",
            "user": "$AUTH_DB_USER",
            "backup_files": [
                "auth-service_full_${TIMESTAMP}.backup",
                "auth-service_full_${TIMESTAMP}.sql",
                "auth-service_schema_${TIMESTAMP}.sql",
                "auth-service_data_${TIMESTAMP}.sql"
            ]
        },
        "account_service": {
            "container": "$ACCOUNT_CONTAINER",
            "database": "$ACCOUNT_DB_NAME",
            "user": "$ACCOUNT_DB_USER",
            "backup_files": [
                "account-service_full_${TIMESTAMP}.backup",
                "account-service_full_${TIMESTAMP}.sql",
                "account-service_schema_${TIMESTAMP}.sql",
                "account-service_data_${TIMESTAMP}.sql"
            ]
        }
    },
    "system_info": {
        "hostname": "$(hostname)",
        "docker_compose_version": "$(docker-compose version --short 2>/dev/null || echo 'unknown')",
        "backup_location": "$BACKUP_DIR"
    }
}
EOF
    
    success "Backup manifest created: $manifest_file"
}

# List database contents for verification
verify_backup_content() {
    local container=$1
    local user=$2
    local db=$3
    local service_name=$4
    
    log "Verifying $service_name database content..."
    
    # List tables
    log "Tables in $service_name database:"
    docker-compose exec -T "$container" psql -U "$user" -d "$db" -c "\dt" 2>/dev/null | tee -a "$LOG_FILE" || true
    
    # Count records in each table
    log "Record counts in $service_name database:"
    docker-compose exec -T "$container" psql -U "$user" -d "$db" -c "
        SELECT schemaname,tablename,n_tup_ins as inserts, n_tup_upd as updates, n_tup_del as deletes 
        FROM pg_stat_user_tables 
        ORDER BY schemaname,tablename;
    " 2>/dev/null | tee -a "$LOG_FILE" || true
}

# Main backup function
main() {
    log "=== Bank Portal Docker Database Backup Started ==="
    
    # Create backup directories
    create_backup_dir
    
    # Check if Docker services are running
    if ! check_services; then
        error "Services not running. Please start with: docker-compose up -d"
        exit 1
    fi
    
    # Check database connections
    if ! check_db_connection "$AUTH_CONTAINER" "$AUTH_DB_USER" "$AUTH_DB_NAME" "auth-service"; then
        error "Cannot connect to auth-service database in container $AUTH_CONTAINER"
        exit 1
    fi
    
    if ! check_db_connection "$ACCOUNT_CONTAINER" "$ACCOUNT_DB_USER" "$ACCOUNT_DB_NAME" "account-service"; then
        error "Cannot connect to account-service database in container $ACCOUNT_CONTAINER"
        exit 1
    fi
    
    # Verify database content before backup
    verify_backup_content "$AUTH_CONTAINER" "$AUTH_DB_USER" "$AUTH_DB_NAME" "auth-service"
    verify_backup_content "$ACCOUNT_CONTAINER" "$ACCOUNT_DB_USER" "$ACCOUNT_DB_NAME" "account-service"
    
    # Backup databases
    local backup_success=true
    
    if ! backup_database "$AUTH_CONTAINER" "$AUTH_DB_USER" "$AUTH_DB_NAME" "auth-service" "$BACKUP_DIR/auth-service/$TIMESTAMP"; then
        backup_success=false
    fi
    
    if ! backup_database "$ACCOUNT_CONTAINER" "$ACCOUNT_DB_USER" "$ACCOUNT_DB_NAME" "account-service" "$BACKUP_DIR/account-service/$TIMESTAMP"; then
        backup_success=false
    fi
    
    if [ "$backup_success" = true ]; then
        # Create manifest
        create_manifest
        
        success "=== Bank Portal Database Backup Completed Successfully ==="
        log "Backup location: $BACKUP_DIR"
        log ""
        log "Available backups:"
        find "$BACKUP_DIR" -name "*.tar.gz" -exec ls -lh {} \;
        log ""
        log "To restore a backup:"
        log "  # Custom format: docker-compose exec postgres-auth pg_restore -U admin -d authdb /path/to/backup.backup"
        log "  # SQL format: docker-compose exec postgres-auth psql -U admin -d authdb < /path/to/backup.sql"
    else
        error "=== Bank Portal Database Backup Failed ==="
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Bank Portal Docker Database Backup System"
        echo "Usage: $0 [options]"
        echo ""
        echo "This script uses docker-compose exec to backup PostgreSQL databases"
        echo "running in Docker containers."
        echo ""
        echo "Prerequisites:"
        echo "  - Docker services must be running (docker-compose up -d)"
        echo "  - No additional PostgreSQL client installation required"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --check        Check prerequisites and connections"
        echo "  --verify       Verify database content"
        echo "  --list         List available backups"
        echo ""
        exit 0
        ;;
    --check)
        log "Checking prerequisites and connections..."
        check_services
        check_db_connection "$AUTH_CONTAINER" "$AUTH_DB_USER" "$AUTH_DB_NAME" "auth-service"
        check_db_connection "$ACCOUNT_CONTAINER" "$ACCOUNT_DB_USER" "$ACCOUNT_DB_NAME" "account-service"
        success "All checks passed!"
        exit 0
        ;;
    --verify)
        log "Verifying database content..."
        verify_backup_content "$AUTH_CONTAINER" "$AUTH_DB_USER" "$AUTH_DB_NAME" "auth-service"
        verify_backup_content "$ACCOUNT_CONTAINER" "$ACCOUNT_DB_USER" "$ACCOUNT_DB_NAME" "account-service"
        exit 0
        ;;
    --list)
        log "Available backups:"
        find "$BACKUP_DIR" -name "*.tar.gz" -type f -exec ls -lh {} \; 2>/dev/null || log "No backups found"
        exit 0
        ;;
    *)
        main
        ;;
esac