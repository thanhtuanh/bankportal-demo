#!/bin/bash

# ⏰ Bank Portal - Automated Backup Scheduler
# Cron-based backup scheduling with monitoring

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/db-backup.sh"
LOG_FILE="/var/log/bankportal-scheduler.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

# Install cron jobs
install_cron() {
    log "Installing backup cron jobs..."
    
    # Create cron entries
    cat > /tmp/bankportal-cron << EOF
# Bank Portal Database Backup Schedule
# Daily backup at 2:00 AM
0 2 * * * $BACKUP_SCRIPT >> $LOG_FILE 2>&1

# Weekly full backup on Sunday at 1:00 AM
0 1 * * 0 $BACKUP_SCRIPT --full >> $LOG_FILE 2>&1

# Monthly cleanup on first day at 3:00 AM
0 3 1 * * $BACKUP_SCRIPT --cleanup >> $LOG_FILE 2>&1

# Health check every 6 hours
0 */6 * * * $SCRIPT_DIR/backup-scheduler.sh --health-check >> $LOG_FILE 2>&1
EOF
    
    # Install cron jobs
    if crontab /tmp/bankportal-cron; then
        success "Cron jobs installed successfully"
        rm /tmp/bankportal-cron
    else
        error "Failed to install cron jobs"
        return 1
    fi
    
    # Show installed cron jobs
    log "Installed cron schedule:"
    crontab -l | grep -E "(Bank Portal|$BACKUP_SCRIPT|$SCRIPT_DIR)"
}

# Remove cron jobs
remove_cron() {
    log "Removing backup cron jobs..."
    
    # Get current crontab without Bank Portal entries
    crontab -l 2>/dev/null | grep -v -E "(Bank Portal|$BACKUP_SCRIPT|$SCRIPT_DIR)" > /tmp/bankportal-cron-clean || true
    
    # Install cleaned crontab
    if crontab /tmp/bankportal-cron-clean; then
        success "Bank Portal cron jobs removed"
        rm /tmp/bankportal-cron-clean
    else
        error "Failed to remove cron jobs"
        return 1
    fi
}

# Health check
health_check() {
    log "Performing backup system health check..."
    
    local issues=0
    
    # Check if backup script exists and is executable
    if [ ! -x "$BACKUP_SCRIPT" ]; then
        error "Backup script not found or not executable: $BACKUP_SCRIPT"
        ((issues++))
    fi
    
    # Check backup directory
    local backup_dir="/var/backups/bankportal"
    if [ ! -d "$backup_dir" ]; then
        warning "Backup directory does not exist: $backup_dir"
        mkdir -p "$backup_dir" 2>/dev/null || ((issues++))
    fi
    
    # Check disk space
    local available_space=$(df "$backup_dir" | awk 'NR==2 {print $4}')
    local min_space=1048576  # 1GB in KB
    
    if [ "$available_space" -lt "$min_space" ]; then
        warning "Low disk space in backup directory: $(($available_space/1024))MB available"
        ((issues++))
    fi
    
    # Check database connectivity
    if ! pg_isready -h localhost -p 5433 -U admin -d authdb > /dev/null 2>&1; then
        error "Cannot connect to auth database"
        ((issues++))
    fi
    
    if ! pg_isready -h localhost -p 5434 -U admin -d accountdb > /dev/null 2>&1; then
        error "Cannot connect to account database"
        ((issues++))
    fi
    
    # Check recent backups
    local recent_backup=$(find "$backup_dir" -name "*.tar.gz" -mtime -1 | wc -l)
    if [ "$recent_backup" -eq 0 ]; then
        warning "No recent backups found (last 24 hours)"
        ((issues++))
    fi
    
    if [ "$issues" -eq 0 ]; then
        success "Health check passed - backup system is healthy"
        return 0
    else
        error "Health check failed - $issues issues found"
        return 1
    fi
}

# Monitor backup status
monitor_backups() {
    log "Monitoring backup status..."
    
    local backup_dir="/var/backups/bankportal"
    
    echo ""
    echo "=== Backup Status Report ==="
    echo ""
    
    # Recent backups
    echo "Recent Backups (last 7 days):"
    find "$backup_dir" -name "*.tar.gz" -mtime -7 -exec ls -lh {} \; 2>/dev/null | sort -k6,7 || echo "No recent backups found"
    
    echo ""
    
    # Disk usage
    echo "Backup Directory Usage:"
    du -sh "$backup_dir" 2>/dev/null || echo "Backup directory not found"
    
    echo ""
    
    # Database sizes
    echo "Database Sizes:"
    export PGPASSWORD="admin"
    
    local auth_size=$(psql -h localhost -p 5433 -U admin -d authdb -t -c "
        SELECT pg_size_pretty(pg_database_size('authdb'));
    " 2>/dev/null | tr -d ' ' || echo "N/A")
    
    local account_size=$(psql -h localhost -p 5434 -U admin -d accountdb -t -c "
        SELECT pg_size_pretty(pg_database_size('accountdb'));
    " 2>/dev/null | tr -d ' ' || echo "N/A")
    
    echo "  Auth Database: $auth_size"
    echo "  Account Database: $account_size"
    
    echo ""
    
    # Backup schedule
    echo "Backup Schedule:"
    crontab -l 2>/dev/null | grep -E "(Bank Portal|$BACKUP_SCRIPT)" || echo "No scheduled backups found"
    
    echo ""
    echo "=== End of Report ==="
}

# Setup backup system
setup() {
    log "Setting up Bank Portal backup system..."
    
    # Create necessary directories
    sudo mkdir -p /var/backups/bankportal
    sudo mkdir -p /var/log
    
    # Set permissions
    sudo chmod 755 /var/backups/bankportal
    sudo touch "$LOG_FILE"
    sudo chmod 644 "$LOG_FILE"
    
    # Make scripts executable
    chmod +x "$BACKUP_SCRIPT"
    chmod +x "$SCRIPT_DIR/db-recovery.sh"
    
    # Install cron jobs
    install_cron
    
    # Run initial health check
    health_check
    
    success "Backup system setup completed"
}

# Show status
status() {
    echo ""
    echo "=== Bank Portal Backup System Status ==="
    echo ""
    
    # Check if cron jobs are installed
    if crontab -l 2>/dev/null | grep -q "$BACKUP_SCRIPT"; then
        echo "✅ Backup scheduler: ACTIVE"
    else
        echo "❌ Backup scheduler: NOT ACTIVE"
    fi
    
    # Check backup script
    if [ -x "$BACKUP_SCRIPT" ]; then
        echo "✅ Backup script: READY"
    else
        echo "❌ Backup script: NOT FOUND"
    fi
    
    # Check databases
    if pg_isready -h localhost -p 5433 -U admin -d authdb > /dev/null 2>&1; then
        echo "✅ Auth database: CONNECTED"
    else
        echo "❌ Auth database: NOT CONNECTED"
    fi
    
    if pg_isready -h localhost -p 5434 -U admin -d accountdb > /dev/null 2>&1; then
        echo "✅ Account database: CONNECTED"
    else
        echo "❌ Account database: NOT CONNECTED"
    fi
    
    # Check recent backups
    local backup_dir="/var/backups/bankportal"
    local recent_backup=$(find "$backup_dir" -name "*.tar.gz" -mtime -1 2>/dev/null | wc -l)
    
    if [ "$recent_backup" -gt 0 ]; then
        echo "✅ Recent backups: $recent_backup found"
    else
        echo "⚠️  Recent backups: NONE (last 24h)"
    fi
    
    echo ""
}

# Main function
main() {
    case "${1:-}" in
        --help|-h)
            echo "Bank Portal Backup Scheduler"
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --help, -h          Show this help message"
            echo "  --setup             Setup backup system and cron jobs"
            echo "  --install-cron      Install cron jobs only"
            echo "  --remove-cron       Remove cron jobs"
            echo "  --health-check      Run health check"
            echo "  --monitor           Show backup monitoring report"
            echo "  --status            Show system status"
            echo ""
            exit 0
            ;;
        --setup)
            setup
            ;;
        --install-cron)
            install_cron
            ;;
        --remove-cron)
            remove_cron
            ;;
        --health-check)
            health_check
            ;;
        --monitor)
            monitor_backups
            ;;
        --status)
            status
            ;;
        *)
            log "Use --help for usage information"
            status
            ;;
    esac
}

# Run main function
main "$@"
