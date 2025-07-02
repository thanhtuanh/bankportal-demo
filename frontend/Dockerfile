# Multi-stage build für Angular Frontend
FROM node:18-alpine AS build

WORKDIR /app

# Package files kopieren
COPY package*.json ./

# Lock-File Problem beheben und Dependencies installieren
RUN rm -f package-lock.json && \
    npm install --legacy-peer-deps

# Source code kopieren und bauen
COPY . .
RUN npm run build:prod

# Production stage mit Nginx
FROM nginx:alpine

# Angular build output kopieren
COPY --from=build /app/dist/bank-portal /usr/share/nginx/html

# Nginx Konfiguration kopieren
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
