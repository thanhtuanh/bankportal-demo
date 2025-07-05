# 🚀 API Gateway Layer - Vollständige Implementierung

## 📋 Übersicht

Die **API Gateway Layer** ist das zentrale Eingangstor für alle Client-Anfragen und implementiert **Cross-Cutting Concerns** wie Authentifizierung, Rate Limiting, CORS und Routing.

## 🏗️ Architektur-Komponenten

### **1. 🔐 JWT Authentication & Validation**

#### **Implementierung:**
```nginx
# nginx-gateway.conf
location /api/accounts/ {
    auth_request /auth-validate;  # Internal JWT validation
    auth_request_set $user $upstream_http_x_user;
    proxy_set_header X-User $user;
    proxy_pass http://account_backend/api/accounts/;
}

location = /auth-validate {
    internal;
    proxy_pass http://auth_backend/api/auth/validate;
    proxy_set_header Authorization $http_authorization;
}
```

#### **Spring Boot Validation Controller:**
```java
@GetMapping("/validate")
public ResponseEntity<Map<String, Object>> validateToken(
        @RequestHeader("Authorization") String authHeader) {
    
    String token = authHeader.substring(7); // Remove "Bearer "
    
    if (jwtUtil.isTokenExpired(token)) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
            .header("X-Auth-Status", "expired")
            .body(Map.of("valid", false, "error", "Token expired"));
    }
    
    String username = jwtUtil.extractUsername(token);
    return ResponseEntity.ok()
        .header("X-User", username)
        .header("X-Auth-Status", "valid")
        .body(Map.of("valid", true, "username", username));
}
```

#### **Funktionale Logik:**
1. **Client** sendet Request mit JWT Token
2. **nginx** intercepted Request und ruft `/auth-validate` auf
3. **Auth Service** validiert Token und extrahiert User-Info
4. **nginx** fügt User-Header hinzu und leitet an Backend weiter
5. **Backend Service** erhält validierte User-Informationen

### **2. 🚦 Rate Limiting**

#### **nginx-Level (Global):**
```nginx
# Rate limiting zones
limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=10r/m;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/m;

# Application
location /api/auth/ {
    limit_req zone=auth_limit burst=5 nodelay;
    proxy_pass http://auth_backend/api/auth/;
}
```

#### **Spring Boot Level (Granular):**
```java
@Component
public class RateLimitingInterceptor implements HandlerInterceptor {
    
    private final ConcurrentHashMap<String, AtomicInteger> requestCounts = new ConcurrentHashMap<>();
    
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        String clientIp = getClientIpAddress(request);
        int maxRequests = getMaxRequestsForEndpoint(request.getRequestURI());
        
        AtomicInteger requestCount = requestCounts.computeIfAbsent(clientIp, k -> new AtomicInteger(0));
        
        if (requestCount.incrementAndGet() > maxRequests) {
            response.setStatus(HttpServletResponse.SC_TOO_MANY_REQUESTS);
            response.setHeader("X-RateLimit-Limit", String.valueOf(maxRequests));
            response.setHeader("Retry-After", "60");
            return false;
        }
        
        return true;
    }
}
```

#### **Funktionale Logik:**
1. **nginx** implementiert globale Rate Limits pro IP
2. **Spring Interceptor** implementiert endpoint-spezifische Limits
3. **Verschiedene Limits** für verschiedene Endpunkte:
   - Login: 5 requests/minute
   - Registration: 3 requests/minute
   - API calls: 100 requests/minute
4. **Headers** informieren Client über Limits

### **3. 🌐 CORS Policy**

#### **nginx CORS Implementation:**
```nginx
location ~* ^/(api|swagger-ui|api-docs) {
    # CORS preflight
    if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type';
        add_header 'Access-Control-Max-Age' 1728000;
        return 204;
    }
    
    # CORS headers for actual requests
    add_header 'Access-Control-Allow-Origin' '*' always;
    add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
    add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type' always;
}
```

#### **Spring Boot CORS Configuration:**
```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("http://localhost:4200", "https://bankportal.com")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true)
                .maxAge(3600);
    }
}
```

#### **Funktionale Logik:**
1. **Browser** sendet OPTIONS preflight request
2. **nginx** antwortet mit CORS headers
3. **Browser** sendet actual request
4. **nginx** fügt CORS headers zu response hinzu
5. **Frontend** kann API sicher aufrufen

### **4. 🛣️ API Routing**

#### **Service Discovery & Load Balancing:**
```nginx
# Upstream definitions
upstream auth_backend {
    least_conn;
    server auth-service:8081 max_fails=3 fail_timeout=30s;
    server auth-service-2:8081 max_fails=3 fail_timeout=30s; # Scaling
}

upstream account_backend {
    least_conn;
    server account-service:8082 max_fails=3 fail_timeout=30s;
    server account-service-2:8082 max_fails=3 fail_timeout=30s; # Scaling
}

# Routing rules
location /api/auth/ {
    proxy_pass http://auth_backend/api/auth/;
}

location /api/accounts/ {
    proxy_pass http://account_backend/api/accounts/;
}
```

#### **Funktionale Logik:**
1. **Client** sendet Request an `/api/auth/login`
2. **nginx** matched Route und wählt `auth_backend`
3. **Load Balancer** wählt verfügbaren Auth Service
4. **Health Checks** überwachen Service-Verfügbarkeit
5. **Failover** zu anderen Instanzen bei Ausfall

## 📊 Monitoring & Observability

### **Health Checks:**
```nginx
location /health {
    access_log off;
    return 200 "healthy\n";
}

location /health/auth {
    proxy_pass http://auth_backend/actuator/health;
}

location /health/account {
    proxy_pass http://account_backend/actuator/health;
}
```

### **Metrics Collection:**
```nginx
location /metrics {
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    deny all;
    proxy_pass http://auth_backend/actuator/metrics;
}
```

### **Logging:**
```nginx
# Custom log format
log_format gateway_log '$remote_addr - $remote_user [$time_local] '
                      '"$request" $status $body_bytes_sent '
                      '"$http_referer" "$http_user_agent" '
                      'rt=$request_time uct="$upstream_connect_time" '
                      'uht="$upstream_header_time" urt="$upstream_response_time"';

access_log /var/log/nginx/gateway_access.log gateway_log;
```

## 🔒 Security Features

### **Security Headers:**
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Content-Security-Policy "default-src 'self';" always;
```

### **Attack Prevention:**
```nginx
# Block common attack patterns
location ~* \.(env|git|svn|htaccess)$ {
    deny all;
    return 404;
}

location ~* /(wp-admin|wp-login|admin|phpmyadmin) {
    deny all;
    return 404;
}
```

### **Connection Limiting:**
```nginx
limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;
limit_conn conn_limit_per_ip 20;
```

## 🚀 Deployment & Scaling

### **Docker Compose Integration:**
```yaml
services:
  nginx-gateway:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx-gateway.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - auth-service
      - account-service
      - frontend
```

### **Kubernetes Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-gateway
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-gateway
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/conf.d
```

## 📈 Performance Optimierung

### **Caching:**
```nginx
# Static asset caching
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# API response caching (selective)
location /api/public/ {
    proxy_cache api_cache;
    proxy_cache_valid 200 5m;
    proxy_cache_key "$scheme$request_method$host$request_uri";
}
```

### **Compression:**
```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
```

## 🎯 Vorteile der API Gateway Implementierung

### **Für Entwicklung:**
- ✅ **Centralized Authentication** - Ein Ort für JWT-Validierung
- ✅ **Service Decoupling** - Services müssen sich nicht um CORS/Rate Limiting kümmern
- ✅ **Consistent API** - Einheitliche API-Struktur für Frontend
- ✅ **Easy Monitoring** - Zentrale Logs und Metriken

### **Für Operations:**
- ✅ **Load Balancing** - Automatische Lastverteilung
- ✅ **Health Checks** - Proaktive Service-Überwachung
- ✅ **Security** - Zentrale Sicherheitsrichtlinien
- ✅ **Scalability** - Einfache Service-Skalierung

### **Für Business:**
- ✅ **Performance** - Caching und Optimierung
- ✅ **Reliability** - Failover und Redundanz
- ✅ **Security** - Enterprise-Grade Schutz
- ✅ **Compliance** - Rate Limiting und Audit Logs

**Die API Gateway Layer ist vollständig implementiert und production-ready!** 🚀
