#!/bin/bash

# 🔄 Bank Portal - Database Recovery System
# Comprehensive recovery solution for PostgreSQL databases

set -e

# Configuration
BACKUP_DIR="/var/backups/bankportal"
LOG_FILE="/var/log/bankportal-recovery.log"

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

# List available backups
list_backups() {
    log "Available backups:"
    echo ""
    echo "Auth Service Backups:"
    find "$BACKUP_DIR/auth-service" -name "*.tar.gz" -type f -exec ls -lh {} \; 2>/dev/null | sort -r
    echo ""
    echo "Account Service Backups:"
    find "$BACKUP_DIR/account-service" -name "*.tar.gz" -type f -exec ls -lh {} \; 2>/dev/null | sort -r
    echo ""
}

# Extract backup
extract_backup() {
    local backup_file=$1
    local extract_dir=$2
    
    log "Extracting backup: $backup_file"
    
    if [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
        return 1
    fi
    
    mkdir -p "$extract_dir"
    if tar -xzf "$backup_file" -C "$extract_dir"; then
        success "Backup extracted to: $extract_dir"
        return 0
    else
        error "Failed to extract backup"
        return 1
    fi
}

# Stop database connections
stop_connections() {
    local host=$1
    local port=$2
    local db=$3
    local user=$4
    local password=$5
    local service_name=$6
    
    log "Stopping connections to $service_name database..."
    
    export PGPASSWORD="$password"
    
    # Terminate existing connections
    psql -h "$host" -p "$port" -U "$user" -d "postgres" -c "
        SELECT pg_terminate_backend(pid) 
        FROM pg_stat_activity 
        WHERE datname = '$db' AND pid <> pg_backend_pid();
    " 2>> "$LOG_FILE" || warning "Could not terminate all connections to $service_name"
    
    success "Connections to $service_name database stopped"
}

# Create database if not exists
create_database() {
    local host=$1
    local port=$2
    local db=$3
    local user=$4
    local password=$5
    local service_name=$6
    
    log "Creating $service_name database if not exists..."
    
    export PGPASSWORD="$password"
    
    # Check if database exists
    if psql -h "$host" -p "$port" -U "$user" -d "postgres" -lqt | cut -d \| -f 1 | grep -qw "$db"; then
        warning "$service_name database already exists"
    else
        if psql -h "$host" -p "$port" -U "$user" -d "postgres" -c "CREATE DATABASE $db;" 2>> "$LOG_FILE"; then
            success "$service_name database created"
        else
            error "Failed to create $service_name database"
            return 1
        fi
    fi
    
    return 0
}

# Drop database
drop_database() {
    local host=$1
    local port=$2
    local db=$3
    local user=$4
    local password=$5
    local service_name=$6
    
    log "Dropping $service_name database..."
    
    export PGPASSWORD="$password"
    
    # Stop connections first
    stop_connections "$host" "$port" "$db" "$user" "$password" "$service_name"
    
    # Drop database
    if psql -h "$host" -p "$port" -U "$user" -d "postgres" -c "DROP DATABASE IF EXISTS $db;" 2>> "$LOG_FILE"; then
        success "$service_name database dropped"
        return 0
    else
        error "Failed to drop $service_name database"
        return 1
    fi
}

# Restore from custom format backup
restore_custom_backup() {
    local host=$1
    local port=$2
    local db=$3
    local user=$4
    local password=$5
    local backup_file=$6
    local service_name=$7
    
    log "Restoring $service_name from custom backup: $backup_file"
    
    export PGPASSWORD="$password"
    
    # Restore using pg_restore
    if pg_restore -h "$host" -p "$port" -U "$user" -d "$db" \
        --verbose --clean --if-exists --create \
        --single-transaction \
        "$backup_file" 2>> "$LOG_FILE"; then
        success "$service_name database restored from custom backup"
        return 0
    else
        error "Failed to restore $service_name from custom backup"
        return 1
    fi
}

# Restore from SQL backup
restore_sql_backup() {
    local host=$1
    local port=$2
    local db=$3
    local user=$4
    local password=$5
    local backup_file=$6
    local service_name=$7
    
    log "Restoring $service_name from SQL backup: $backup_file"
    
    export PGPASSWORD="$password"
    
    # Restore using psql
    if psql -h "$host" -p "$port" -U "$user" -d "$db" \
        -f "$backup_file" 2>> "$LOG_FILE"; then
        success "$service_name database restored from SQL backup"
        return 0
    else
        error "Failed to restore $service_name from SQL backup"
        return 1
    fi
}

# Verify database after restoration
verify_restoration() {
    local host=$1
    local port=$2
    local db=$3
    local user=$4
    local password=$5
    local service_name=$6
    
    log "Verifying $service_name database restoration..."
    
    export PGPASSWORD="$password"
    
    # Check if database is accessible
    if ! pg_isready -h "$host" -p "$port" -U "$user" -d "$db" > /dev/null 2>&1; then
        error "$service_name database is not accessible after restoration"
        return 1
    fi
    
    # Check table count
    local table_count=$(psql -h "$host" -p "$port" -U "$user" -d "$db" -t -c "
        SELECT COUNT(*) FROM information_schema.tables 
        WHERE table_schema = 'public';
    " 2>/dev/null | tr -d ' ')
    
    if [ "$table_count" -gt 0 ]; then
        success "$service_name database verification passed ($table_count tables found)"
        return 0
    else
        warning "$service_name database has no tables"
        return 1
    fi
}

# Point-in-time recovery
point_in_time_recovery() {
    local service_name=$1
    local target_time=$2
    
    log "Performing point-in-time recovery for $service_name to $target_time"
    
    # This would require WAL archiving to be enabled
    warning "Point-in-time recovery requires WAL archiving configuration"
    warning "This is a placeholder for PITR implementation"
    
    # Implementation would involve:
    # 1. Restore from base backup
    # 2. Apply WAL files up to target time
    # 3. Create recovery.conf with target time
    
    return 0
}

# Interactive recovery menu
interactive_recovery() {
    echo ""
    echo "=== Bank Portal Database Recovery System ==="
    echo ""
    
    # List available backups
    list_backups
    
    echo ""
    echo "Recovery Options:"
    echo "1. Restore Auth Service"
    echo "2. Restore Account Service"
    echo "3. Restore Both Services"
    echo "4. Point-in-time Recovery"
    echo "5. Exit"
    echo ""
    
    read -p "Select option (1-5): " choice
    
    case $choice in
        1)
            echo ""
            read -p "Enter auth service backup file path: " backup_file
            read -p "Confirm restoration (this will DROP existing data) [y/N]: " confirm
            
            if [[ $confirm =~ ^[Yy]$ ]]; then
                recover_service "auth" "$backup_file"
            else
                log "Auth service recovery cancelled"
            fi
            ;;
        2)
            echo ""
            read -p "Enter account service backup file path: " backup_file
            read -p "Confirm restoration (this will DROP existing data) [y/N]: " confirm
            
            if [[ $confirm =~ ^[Yy]$ ]]; then
                recover_service "account" "$backup_file"
            else
                log "Account service recovery cancelled"
            fi
            ;;
        3)
            echo ""
            read -p "Enter backup timestamp (YYYYMMDD_HHMMSS): " timestamp
            read -p "Confirm restoration of BOTH services (this will DROP existing data) [y/N]: " confirm
            
            if [[ $confirm =~ ^[Yy]$ ]]; then
                recover_both_services "$timestamp"
            else
                log "Full recovery cancelled"
            fi
            ;;
        4)
            echo ""
            read -p "Enter target time (YYYY-MM-DD HH:MM:SS): " target_time
            read -p "Enter service (auth/account): " service
            point_in_time_recovery "$service" "$target_time"
            ;;
        5)
            log "Exiting recovery system"
            exit 0
            ;;
        *)
            error "Invalid option selected"
            exit 1
            ;;
    esac
}

# Recover specific service
recover_service() {
    local service=$1
    local backup_file=$2
    
    log "=== Starting $service service recovery ==="
    
    if [ "$service" = "auth" ]; then
        local host="$AUTH_DB_HOST"
        local port="$AUTH_DB_PORT"
        local db="$AUTH_DB_NAME"
        local user="$AUTH_DB_USER"
        local password="$AUTH_DB_PASSWORD"
    elif [ "$service" = "account" ]; then
        local host="$ACCOUNT_DB_HOST"
        local port="$ACCOUNT_DB_PORT"
        local db="$ACCOUNT_DB_NAME"
        local user="$ACCOUNT_DB_USER"
        local password="$ACCOUNT_DB_PASSWORD"
    else
        error "Invalid service: $service"
        return 1
    fi
    
    # Extract backup if it's compressed
    local extract_dir="/tmp/bankportal_recovery_$$"
    if [[ "$backup_file" == *.tar.gz ]]; then
        extract_backup "$backup_file" "$extract_dir"
        # Find the actual backup file
        backup_file=$(find "$extract_dir" -name "*_full_*.backup" | head -1)
        if [ -z "$backup_file" ]; then
            backup_file=$(find "$extract_dir" -name "*_full_*.sql" | head -1)
        fi
    fi
    
    if [ ! -f "$backup_file" ]; then
        error "Backup file not found: $backup_file"
        return 1
    fi
    
    # Drop and recreate database
    drop_database "$host" "$port" "$db" "$user" "$password" "$service"
    create_database "$host" "$port" "$db" "$user" "$password" "$service"
    
    # Restore based on file type
    if [[ "$backup_file" == *.backup ]]; then
        restore_custom_backup "$host" "$port" "$db" "$user" "$password" "$backup_file" "$service"
    else
        restore_sql_backup "$host" "$port" "$db" "$user" "$password" "$backup_file" "$service"
    fi
    
    # Verify restoration
    verify_restoration "$host" "$port" "$db" "$user" "$password" "$service"
    
    # Cleanup
    rm -rf "$extract_dir" 2>/dev/null
    
    success "=== $service service recovery completed ==="
}

# Recover both services
recover_both_services() {
    local timestamp=$1
    
    log "=== Starting full system recovery for timestamp: $timestamp ==="
    
    local auth_backup="$BACKUP_DIR/auth-service/$timestamp/auth-service_backup_${timestamp}.tar.gz"
    local account_backup="$BACKUP_DIR/account-service/$timestamp/account-service_backup_${timestamp}.tar.gz"
    
    if [ ! -f "$auth_backup" ] || [ ! -f "$account_backup" ]; then
        error "Backup files not found for timestamp: $timestamp"
        return 1
    fi
    
    # Recover both services
    recover_service "auth" "$auth_backup"
    recover_service "account" "$account_backup"
    
    success "=== Full system recovery completed ==="
}

# Main function
main() {
    case "${1:-}" in
        --help|-h)
            echo "Bank Portal Database Recovery System"
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --help, -h              Show this help message"
            echo "  --list                  List available backups"
            echo "  --interactive, -i       Interactive recovery mode"
            echo "  --auth <backup_file>    Restore auth service"
            echo "  --account <backup_file> Restore account service"
            echo "  --full <timestamp>      Restore both services"
            echo ""
            exit 0
            ;;
        --list)
            list_backups
            ;;
        --interactive|-i)
            interactive_recovery
            ;;
        --auth)
            if [ -z "$2" ]; then
                error "Backup file path required"
                exit 1
            fi
            recover_service "auth" "$2"
            ;;
        --account)
            if [ -z "$2" ]; then
                error "Backup file path required"
                exit 1
            fi
            recover_service "account" "$2"
            ;;
        --full)
            if [ -z "$2" ]; then
                error "Timestamp required"
                exit 1
            fi
            recover_both_services "$2"
            ;;
        *)
            log "Starting interactive recovery mode..."
            interactive_recovery
            ;;
    esac
}

# Run main function
main "$@"
