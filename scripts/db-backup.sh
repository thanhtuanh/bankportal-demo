#!/bin/bash

# 💾 Bank Portal - Database Backup System
# Comprehensive backup solution for PostgreSQL databases

set -e

# Configuration
BACKUP_DIR="/var/backups/bankportal"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30
LOG_FILE="/var/log/bankportal-backup.log"

# Database Configuration
AUTH_DB_HOST="localhost"
AUTH_DB_PORT="5433"
AUTH_DB_NAME="authdb"
AUTH_DB_USER="admin"
AUTH_DB_PASSWORD="admin"

ACCOUNT_DB_HOST="localhost"
ACCOUNT_DB_PORT="5434"
ACCOUNT_DB_NAME="accountdb"
ACCOUNT_DB_USER="admin"
ACCOUNT_DB_PASSWORD="admin"

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
    success "Backup directories created"
}

# Check database connectivity
check_db_connection() {
    local host=$1
    local port=$2
    local db=$3
    local user=$4
    local password=$5
    local service_name=$6
    
    log "Checking connection to $service_name database..."
    
    export PGPASSWORD="$password"
    if pg_isready -h "$host" -p "$port" -U "$user" -d "$db" > /dev/null 2>&1; then
        success "$service_name database is accessible"
        return 0
    else
        error "$service_name database is not accessible"
        return 1
    fi
}

# Backup individual database
backup_database() {
    local host=$1
    local port=$2
    local db=$3
    local user=$4
    local password=$5
    local service_name=$6
    local backup_path=$7
    
    log "Starting backup for $service_name database..."
    
    export PGPASSWORD="$password"
    
    # Full database dump
    local dump_file="$backup_path/${service_name}_full_${TIMESTAMP}.sql"
    if pg_dump -h "$host" -p "$port" -U "$user" -d "$db" \
        --verbose --clean --if-exists --create \
        --format=custom --compress=9 \
        --file="$dump_file.backup" 2>> "$LOG_FILE"; then
        success "$service_name database backup completed: $dump_file.backup"
    else
        error "Failed to backup $service_name database"
        return 1
    fi
    
    # Plain SQL dump for readability
    if pg_dump -h "$host" -p "$port" -U "$user" -d "$db" \
        --verbose --clean --if-exists --create \
        --format=plain \
        --file="$dump_file" 2>> "$LOG_FILE"; then
        success "$service_name plain SQL dump completed: $dump_file"
    else
        warning "Failed to create plain SQL dump for $service_name"
    fi
    
    # Schema-only backup
    local schema_file="$backup_path/${service_name}_schema_${TIMESTAMP}.sql"
    if pg_dump -h "$host" -p "$port" -U "$user" -d "$db" \
        --schema-only --verbose \
        --file="$schema_file" 2>> "$LOG_FILE"; then
        success "$service_name schema backup completed: $schema_file"
    else
        warning "Failed to backup $service_name schema"
    fi
    
    # Data-only backup
    local data_file="$backup_path/${service_name}_data_${TIMESTAMP}.sql"
    if pg_dump -h "$host" -p "$port" -U "$user" -d "$db" \
        --data-only --verbose \
        --file="$data_file" 2>> "$LOG_FILE"; then
        success "$service_name data backup completed: $data_file"
    else
        warning "Failed to backup $service_name data"
    fi
    
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
        "type": "full_backup"
    },
    "databases": {
        "auth_service": {
            "host": "$AUTH_DB_HOST",
            "port": "$AUTH_DB_PORT",
            "database": "$AUTH_DB_NAME",
            "backup_files": [
                "auth-service_full_${TIMESTAMP}.sql.backup",
                "auth-service_full_${TIMESTAMP}.sql",
                "auth-service_schema_${TIMESTAMP}.sql",
                "auth-service_data_${TIMESTAMP}.sql"
            ]
        },
        "account_service": {
            "host": "$ACCOUNT_DB_HOST",
            "port": "$ACCOUNT_DB_PORT",
            "database": "$ACCOUNT_DB_NAME",
            "backup_files": [
                "account-service_full_${TIMESTAMP}.sql.backup",
                "account-service_full_${TIMESTAMP}.sql",
                "account-service_schema_${TIMESTAMP}.sql",
                "account-service_data_${TIMESTAMP}.sql"
            ]
        }
    },
    "system_info": {
        "hostname": "$(hostname)",
        "postgres_version": "$(psql --version | head -n1)",
        "backup_tool": "pg_dump",
        "compression": "gzip"
    }
}
EOF
    
    success "Backup manifest created: $manifest_file"
}

# Cleanup old backups
cleanup_old_backups() {
    log "Cleaning up backups older than $RETENTION_DAYS days..."
    
    find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete 2>> "$LOG_FILE"
    find "$BACKUP_DIR" -type f -name "*.sql" -mtime +$RETENTION_DAYS -delete 2>> "$LOG_FILE"
    find "$BACKUP_DIR" -type f -name "*.backup" -mtime +$RETENTION_DAYS -delete 2>> "$LOG_FILE"
    
    # Remove empty directories
    find "$BACKUP_DIR" -type d -empty -delete 2>> "$LOG_FILE"
    
    success "Old backups cleaned up"
}

# Verify backup integrity
verify_backup() {
    local backup_file=$1
    local service_name=$2
    
    log "Verifying $service_name backup integrity..."
    
    if [ -f "$backup_file" ]; then
        # Check if backup file is not empty
        if [ -s "$backup_file" ]; then
            # For custom format backups, use pg_restore to list contents
            if [[ "$backup_file" == *.backup ]]; then
                if pg_restore --list "$backup_file" > /dev/null 2>&1; then
                    success "$service_name backup verification passed"
                    return 0
                else
                    error "$service_name backup verification failed"
                    return 1
                fi
            else
                success "$service_name backup file exists and is not empty"
                return 0
            fi
        else
            error "$service_name backup file is empty"
            return 1
        fi
    else
        error "$service_name backup file not found"
        return 1
    fi
}

# Send backup notification
send_notification() {
    local status=$1
    local message=$2
    
    # This could be extended to send email, Slack, etc.
    log "NOTIFICATION: $status - $message"
    
    # Example: Send to webhook (uncomment and configure)
    # curl -X POST -H 'Content-type: application/json' \
    #     --data "{\"text\":\"Bank Portal Backup $status: $message\"}" \
    #     "$SLACK_WEBHOOK_URL"
}

# Main backup function
main() {
    log "=== Bank Portal Database Backup Started ==="
    
    # Check if running as root or with sufficient privileges
    if [[ $EUID -ne 0 ]] && [[ ! -w "$BACKUP_DIR" ]]; then
        warning "Running without root privileges. Ensure backup directory is writable."
    fi
    
    # Create backup directories
    create_backup_dir
    
    # Check database connections
    if ! check_db_connection "$AUTH_DB_HOST" "$AUTH_DB_PORT" "$AUTH_DB_NAME" "$AUTH_DB_USER" "$AUTH_DB_PASSWORD" "auth-service"; then
        error "Cannot connect to auth-service database. Backup aborted."
        send_notification "FAILED" "Cannot connect to auth-service database"
        exit 1
    fi
    
    if ! check_db_connection "$ACCOUNT_DB_HOST" "$ACCOUNT_DB_PORT" "$ACCOUNT_DB_NAME" "$ACCOUNT_DB_USER" "$ACCOUNT_DB_PASSWORD" "account-service"; then
        error "Cannot connect to account-service database. Backup aborted."
        send_notification "FAILED" "Cannot connect to account-service database"
        exit 1
    fi
    
    # Backup databases
    local backup_success=true
    
    if ! backup_database "$AUTH_DB_HOST" "$AUTH_DB_PORT" "$AUTH_DB_NAME" "$AUTH_DB_USER" "$AUTH_DB_PASSWORD" "auth-service" "$BACKUP_DIR/auth-service/$TIMESTAMP"; then
        backup_success=false
    fi
    
    if ! backup_database "$ACCOUNT_DB_HOST" "$ACCOUNT_DB_PORT" "$ACCOUNT_DB_NAME" "$ACCOUNT_DB_USER" "$ACCOUNT_DB_PASSWORD" "account-service" "$BACKUP_DIR/account-service/$TIMESTAMP"; then
        backup_success=false
    fi
    
    if [ "$backup_success" = true ]; then
        # Create manifest
        create_manifest
        
        # Verify backups
        verify_backup "$BACKUP_DIR/auth-service/$TIMESTAMP/auth-service_full_${TIMESTAMP}.sql.backup" "auth-service"
        verify_backup "$BACKUP_DIR/account-service/$TIMESTAMP/account-service_full_${TIMESTAMP}.sql.backup" "account-service"
        
        # Cleanup old backups
        cleanup_old_backups
        
        success "=== Bank Portal Database Backup Completed Successfully ==="
        send_notification "SUCCESS" "All databases backed up successfully at $TIMESTAMP"
    else
        error "=== Bank Portal Database Backup Failed ==="
        send_notification "FAILED" "Database backup failed at $TIMESTAMP"
        exit 1
    fi
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Bank Portal Database Backup System"
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --verify       Verify existing backups"
        echo "  --cleanup      Cleanup old backups only"
        echo "  --list         List available backups"
        echo ""
        exit 0
        ;;
    --verify)
        log "Verifying existing backups..."
        # Add verification logic here
        exit 0
        ;;
    --cleanup)
        log "Cleaning up old backups..."
        cleanup_old_backups
        exit 0
        ;;
    --list)
        log "Available backups:"
        find "$BACKUP_DIR" -name "*.tar.gz" -type f -exec ls -lh {} \;
        exit 0
        ;;
    *)
        main
        ;;
esac
