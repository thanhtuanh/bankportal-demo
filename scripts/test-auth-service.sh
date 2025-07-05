#!/bin/bash

# 🧪 Auth Service Local Testing Script
# Tests the auth service without Docker dependencies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Configuration
AUTH_SERVICE_URL="http://localhost:8081"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Start auth service in development mode
start_auth_service() {
    log "Starting Auth Service in development mode..."
    
    cd "$PROJECT_DIR/auth-service"
    
    # Check if Maven is available
    if ! command -v mvn &> /dev/null; then
        error "Maven is not installed or not in PATH"
        return 1
    fi
    
    # Start with dev profile (H2 database)
    log "Starting with development profile (H2 in-memory database)..."
    mvn spring-boot:run -Dspring-boot.run.profiles=dev &
    
    # Store PID for cleanup
    AUTH_PID=$!
    echo $AUTH_PID > /tmp/auth-service.pid
    
    log "Auth Service started with PID: $AUTH_PID"
    log "Waiting for service to be ready..."
    
    # Wait for service to start
    for i in {1..30}; do
        if curl -s "$AUTH_SERVICE_URL/api/health" > /dev/null 2>&1; then
            success "Auth Service is ready!"
            return 0
        fi
        echo -n "."
        sleep 2
    done
    
    error "Auth Service failed to start within 60 seconds"
    return 1
}

# Stop auth service
stop_auth_service() {
    log "Stopping Auth Service..."
    
    if [ -f /tmp/auth-service.pid ]; then
        local pid=$(cat /tmp/auth-service.pid)
        if kill -0 $pid 2>/dev/null; then
            kill $pid
            success "Auth Service stopped (PID: $pid)"
        else
            warning "Auth Service was not running"
        fi
        rm -f /tmp/auth-service.pid
    else
        warning "No PID file found"
    fi
}

# Test health endpoints
test_health() {
    log "Testing health endpoints..."
    
    # Test basic health
    if curl -s "$AUTH_SERVICE_URL/api/health" | grep -q "UP"; then
        success "Health endpoint: OK"
    else
        error "Health endpoint: FAILED"
        return 1
    fi
    
    # Test status endpoint
    if curl -s "$AUTH_SERVICE_URL/api/status" | grep -q "RUNNING"; then
        success "Status endpoint: OK"
    else
        error "Status endpoint: FAILED"
        return 1
    fi
    
    # Test swagger test endpoint
    if curl -s "$AUTH_SERVICE_URL/api/swagger-test" | grep -q "swagger_status"; then
        success "Swagger test endpoint: OK"
    else
        error "Swagger test endpoint: FAILED"
        return 1
    fi
}

# Test Swagger endpoints
test_swagger() {
    log "Testing Swagger endpoints..."
    
    # Test API docs
    local api_docs_status=$(curl -s -o /dev/null -w "%{http_code}" "$AUTH_SERVICE_URL/api-docs")
    if [ "$api_docs_status" = "200" ]; then
        success "API docs endpoint: OK (HTTP $api_docs_status)"
    else
        error "API docs endpoint: FAILED (HTTP $api_docs_status)"
        return 1
    fi
    
    # Test Swagger UI
    local swagger_ui_status=$(curl -s -o /dev/null -w "%{http_code}" "$AUTH_SERVICE_URL/swagger-ui.html")
    if [ "$swagger_ui_status" = "200" ]; then
        success "Swagger UI: OK (HTTP $swagger_ui_status)"
    else
        error "Swagger UI: FAILED (HTTP $swagger_ui_status)"
        return 1
    fi
}

# Test JWT validation endpoints
test_jwt_validation() {
    log "Testing JWT validation endpoints..."
    
    # Test validation endpoint without token (should return 401)
    local validation_status=$(curl -s -o /dev/null -w "%{http_code}" "$AUTH_SERVICE_URL/api/auth/validate")
    if [ "$validation_status" = "401" ]; then
        success "JWT validation endpoint: OK (correctly returns 401 without token)"
    else
        warning "JWT validation endpoint: Unexpected status $validation_status"
    fi
    
    # Test user info endpoint without token (should return 401)
    local userinfo_status=$(curl -s -o /dev/null -w "%{http_code}" "$AUTH_SERVICE_URL/api/auth/user-info")
    if [ "$userinfo_status" = "401" ]; then
        success "User info endpoint: OK (correctly returns 401 without token)"
    else
        warning "User info endpoint: Unexpected status $userinfo_status"
    fi
}

# Show service URLs
show_urls() {
    echo ""
    echo "=== Auth Service URLs ==="
    echo "Health Check:    $AUTH_SERVICE_URL/api/health"
    echo "Status:          $AUTH_SERVICE_URL/api/status"
    echo "Swagger Test:    $AUTH_SERVICE_URL/api/swagger-test"
    echo "API Docs:        $AUTH_SERVICE_URL/api-docs"
    echo "Swagger UI:      $AUTH_SERVICE_URL/swagger-ui.html"
    echo "JWT Validation:  $AUTH_SERVICE_URL/api/auth/validate"
    echo "User Info:       $AUTH_SERVICE_URL/api/auth/user-info"
    echo "H2 Console:      $AUTH_SERVICE_URL/h2-console"
    echo ""
}

# Cleanup function
cleanup() {
    log "Cleaning up..."
    stop_auth_service
}

# Set trap for cleanup
trap cleanup EXIT

# Main function
main() {
    case "${1:-}" in
        --help|-h)
            echo "Auth Service Local Testing Script"
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --help, -h      Show this help message"
            echo "  --start         Start auth service only"
            echo "  --test          Run tests only (service must be running)"
            echo "  --stop          Stop auth service"
            echo "  --urls          Show service URLs"
            echo ""
            echo "Default: Start service and run all tests"
            exit 0
            ;;
        --start)
            start_auth_service
            show_urls
            log "Auth Service is running. Press Ctrl+C to stop."
            wait
            ;;
        --test)
            log "Running tests against running service..."
            test_health
            test_swagger
            test_jwt_validation
            success "All tests completed!"
            ;;
        --stop)
            stop_auth_service
            ;;
        --urls)
            show_urls
            ;;
        *)
            log "=== Auth Service Local Test ==="
            
            # Start service
            if start_auth_service; then
                show_urls
                
                # Run tests
                log "Running comprehensive tests..."
                test_health
                test_swagger
                test_jwt_validation
                
                success "=== All tests passed! ==="
                log "Service is running. Check the URLs above."
                log "Press Ctrl+C to stop the service."
                
                # Keep running
                wait
            else
                error "Failed to start Auth Service"
                exit 1
            fi
            ;;
    esac
}

# Run main function
main "$@"
