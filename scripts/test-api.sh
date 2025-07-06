#!/bin/bash
# API Testing Script für Bank Portal

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

echo "🧪 Bank Portal API Tests"
echo "======================="

# Test Auth Service Health
log_info "Testing Auth Service Health..."
if curl -s -f http://localhost:8081/actuator/health > /dev/null 2>&1; then
    log_success "Auth Service Health OK"
else
    log_error "Auth Service Health FAILED"
fi

# Test Account Service Health
log_info "Testing Account Service Health..."
if curl -s -f http://localhost:8082/actuator/health > /dev/null 2>&1; then
    log_success "Account Service Health OK"
else
    log_error "Account Service Health FAILED"
fi

# Test Frontend
log_info "Testing Frontend..."
if curl -s -f http://localhost:4200 > /dev/null 2>&1; then
    log_success "Frontend OK"
else
    log_error "Frontend FAILED"
fi

# Test User Registration
# ⏰ Generiere einen eindeutigen Usernamen
UNIQUE_USER="testuser_$(date +%s)"

log_info "Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"$UNIQUE_USER\", \"password\": \"password123\"}")

if echo "$REGISTER_RESPONSE" | grep -q "erfolgreich"; then
    log_success "User Registration OK"
else
    log_error "User Registration FAILED: $REGISTER_RESPONSE"
fi

# 👇 Login muss denselben Usernamen verwenden!
log_info "Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\": \"$UNIQUE_USER\", \"password\": \"password123\"}")

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    log_success "User Login OK"
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    log_info "Testing Account Service with JWT Token..."
    ACCOUNTS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8082/api/accounts)
    
    if echo "$ACCOUNTS_RESPONSE" | grep -q "\["; then
        log_success "Account Service with JWT OK"
    else
        log_error "Account Service with JWT FAILED: $ACCOUNTS_RESPONSE"
    fi
else
    log_error "User Login FAILED: $LOGIN_RESPONSE"
fi

echo ""
echo "🎯 API Tests abgeschlossen!"
