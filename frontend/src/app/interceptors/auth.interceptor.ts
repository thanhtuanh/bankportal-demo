import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  console.log('🔍 Intercepting request to:', req.url);
  
  // Register und Login Requests NICHT intercepten
  const authEndpoints = ['/auth/register', '/auth/login'];
  const isAuthEndpoint = authEndpoints.some(endpoint => req.url.includes(endpoint));
  
  if (isAuthEndpoint) {
    console.log('🔓 Auth endpoint detected, skipping token');
    return next(req);
  }

  const token = localStorage.getItem('token');
  console.log('🔑 Token available:', !!token);

  if (token) {
    const authReq = req.clone({
      setHeaders: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Token added to request');
    return next(authReq);
  }

  console.log('ℹ️ No token, proceeding without authorization');
  return next(req);
};
