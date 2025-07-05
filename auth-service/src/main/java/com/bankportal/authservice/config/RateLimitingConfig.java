package com.bankportal.authservice.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Configuration
public class RateLimitingConfig implements WebMvcConfigurer {

    @Bean
    public RateLimitingInterceptor rateLimitingInterceptor() {
        return new RateLimitingInterceptor();
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(rateLimitingInterceptor())
                .addPathPatterns("/api/auth/**")
                .excludePathPatterns("/api/auth/validate", "/actuator/**");
    }

    public static class RateLimitingInterceptor implements HandlerInterceptor {
        
        // Rate limiting storage: IP -> Request count
        private final ConcurrentHashMap<String, AtomicInteger> requestCounts = new ConcurrentHashMap<>();
        
        // Configuration
        private static final int MAX_REQUESTS_PER_MINUTE = 10;
        private static final int WINDOW_SIZE_MINUTES = 1;
        
        // Scheduler for cleanup
        private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
        
        public RateLimitingInterceptor() {
            // Clean up old entries every minute
            scheduler.scheduleAtFixedRate(this::cleanupOldEntries, 1, 1, TimeUnit.MINUTES);
        }

        @Override
        public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
            
            String clientIp = getClientIpAddress(request);
            String endpoint = request.getRequestURI();
            
            // Different limits for different endpoints
            int maxRequests = getMaxRequestsForEndpoint(endpoint);
            
            // Get current request count for this IP
            AtomicInteger requestCount = requestCounts.computeIfAbsent(clientIp, k -> new AtomicInteger(0));
            
            int currentCount = requestCount.incrementAndGet();
            
            if (currentCount > maxRequests) {
                // Rate limit exceeded - HTTP 429 Too Many Requests
                response.setStatus(429);
                response.setContentType("application/json");
                response.getWriter().write(String.format(
                    "{\"error\":\"Rate limit exceeded\",\"limit\":%d,\"window\":\"%d minutes\",\"retry_after\":60}",
                    maxRequests, WINDOW_SIZE_MINUTES
                ));
                
                // Add rate limiting headers
                response.setHeader("X-RateLimit-Limit", String.valueOf(maxRequests));
                response.setHeader("X-RateLimit-Remaining", "0");
                response.setHeader("X-RateLimit-Reset", String.valueOf(System.currentTimeMillis() + 60000));
                response.setHeader("Retry-After", "60");
                
                return false;
            }
            
            // Add rate limiting headers for successful requests
            response.setHeader("X-RateLimit-Limit", String.valueOf(maxRequests));
            response.setHeader("X-RateLimit-Remaining", String.valueOf(maxRequests - currentCount));
            response.setHeader("X-RateLimit-Reset", String.valueOf(System.currentTimeMillis() + 60000));
            
            return true;
        }
        
        private String getClientIpAddress(HttpServletRequest request) {
            // Check for IP from nginx proxy
            String xForwardedFor = request.getHeader("X-Forwarded-For");
            if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
                return xForwardedFor.split(",")[0].trim();
            }
            
            String xRealIp = request.getHeader("X-Real-IP");
            if (xRealIp != null && !xRealIp.isEmpty()) {
                return xRealIp;
            }
            
            return request.getRemoteAddr();
        }
        
        private int getMaxRequestsForEndpoint(String endpoint) {
            // Different rate limits for different endpoints
            if (endpoint.contains("/login")) {
                return 5; // Stricter limit for login attempts
            } else if (endpoint.contains("/register")) {
                return 3; // Very strict for registration
            } else if (endpoint.contains("/validate")) {
                return 1000; // High limit for internal validation
            }
            
            return MAX_REQUESTS_PER_MINUTE; // Default limit
        }
        
        private void cleanupOldEntries() {
            // Reset all counters every minute (sliding window)
            requestCounts.clear();
        }
    }
}
