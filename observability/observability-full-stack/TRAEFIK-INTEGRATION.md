# 🚪 Traefik External Proxy Integration Guide

This guide explains how to integrate the observability monitoring stack with an external Traefik reverse proxy.

## 📋 **Overview**

Since the monitoring stack runs without its own Traefik instance, you can integrate it with your existing external Traefik proxy to provide:
- HTTPS termination with automatic SSL certificates
- Domain-based routing to services
- Basic authentication for secure access
- Centralized traffic management

## 🛠️ **Quick Start**

### **Step 1: Configure Environment**
```bash
cd observability/observability-full-stack
cp .env.example .env
# Edit .env with your actual values:
# - VM_IP=192.168.80.25
# - DOMAIN_ADDRESS=monlog.erahyar.com
# - WEB_AUTH_PASS={SHA}hashed_password
```

### **Step 2: Generate Traefik Configuration**
```bash
./generate-traefik-config.sh
```

### **Step 3: Deploy to External Traefik**
```bash
# Copy configuration to your Traefik dynamic config directory
cp traefik-config.yml /path/to/traefik/dynamic/
# Or add labels from traefik-labels.txt to your Docker services
```

## 📁 **Generated Files**

### **`traefik-config.yml`**
Complete Traefik configuration for file-based provider with:
- HTTP to HTTPS redirects
- SSL certificate management 
- Basic authentication middleware
- Service routing and load balancing

### **`traefik-labels.txt`**
Docker Compose labels for container-based Traefik discovery:
- Ready-to-use labels for each service
- Automatic service discovery configuration
- Middleware assignments

## 🌐 **Service Endpoints**

After integration, your services will be accessible via:

| Service | Internal URL | External URL |
|---------|-------------|--------------|
| Prometheus | http://192.168.80.25:9090 | https://metrics.monlog.erahyar.com |
| Grafana | http://192.168.80.25:3000 | https://grafana.monlog.erahyar.com |
| AlertManager | http://192.168.80.25:9093 | https://alerts.monlog.erahyar.com |
| Pushgateway | http://192.168.80.25:9091 | https://pushgw.monlog.erahyar.com |
| Loki | http://192.168.80.25:3100 | https://loki.monlog.erahyar.com |

## 🔧 **Traefik Configuration Methods**

### **Method 1: File Provider (Recommended)**

**Traefik Configuration (traefik.yml):**
```yaml
providers:
  file:
    directory: /etc/traefik/dynamic
    watch: true

certificatesResolvers:
  mycert:
    acme:
      email: admin@erahyar.com
      storage: /data/acme.json
      httpChallenge:
        entryPoint: web
```

**Usage:**
```bash
# Copy generated config to Traefik
cp traefik-config.yml /etc/traefik/dynamic/observability.yml
# Traefik automatically reloads the configuration
```

### **Method 2: Docker Provider**

**Traefik Configuration (traefik.yml):**
```yaml
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
    network: web_net
```

**Usage:**
Add labels from `traefik-labels.txt` to your Docker Compose services:
```yaml
services:
  prometheus:
    image: prom/prometheus
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=web_net"
      - "traefik.http.routers.prometheus.rule=Host(`metrics.monlog.erahyar.com`)"
      # ... additional labels from traefik-labels.txt
```

## 🔐 **Security Configuration**

### **Basic Authentication Setup**

**Generate Password Hash:**
```bash
# Generate SHA hash for web authentication
echo "your_password" | htpasswd -s -n -i admin
# Output: admin:{SHA}Ne0GBlaxUeH02aZ1+MabHvXMBv4=
```

**Required Middleware (traefik.yml):**
```yaml
http:
  middlewares:
    web-auth:
      basicAuth:
        users:
          - "admin:{SHA}Ne0GBlaxUeH02aZ1+MabHvXMBv4="
    https-redirect:
      redirectScheme:
        scheme: https
        permanent: true
```

### **SSL Certificate Management**

**Automatic Certificates:**
```yaml
certificatesResolvers:
  mycert:
    acme:
      email: admin@erahyar.com
      storage: /data/acme.json
      httpChallenge:
        entryPoint: web
      # Or use DNS challenge for wildcard certificates:
      # dnsChallenge:
      #   provider: cloudflare
```

## 🚀 **Deployment Scenarios**

### **Scenario 1: Separate Traefik Server**
```bash
# On Traefik server (e.g., 192.168.80.20)
cp traefik-config.yml /etc/traefik/dynamic/observability.yml
systemctl reload traefik

# Services route from Traefik server to monitoring server
# Traefik (80.20) → Monitoring Stack (80.25)
```

### **Scenario 2: Docker Swarm/Compose**
```bash
# Add to your existing docker-compose.yml with Traefik
version: '3.8'
services:
  traefik:
    # ... existing traefik config
    
  # Add monitoring services with labels
  prometheus:
    image: prom/prometheus
    networks:
      - web_net
    labels: # Add labels from traefik-labels.txt
```

### **Scenario 3: Kubernetes (Future)**
```yaml
# Convert to Kubernetes Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: observability-ingress
  annotations:
    traefik.ingress.kubernetes.io/router.middlewares: web-auth@kubernetescrd
spec:
  rules:
  - host: metrics.monlog.erahyar.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-service
            port:
              number: 9090
```

## 🧪 **Testing Integration**

### **Configuration Validation**
```bash
# Test Traefik config syntax
traefik --configfile=/etc/traefik/traefik.yml --checkconsoleconfig

# Test generated YAML syntax
yq eval '.' traefik-config.yml

# Test SSL certificate resolver
curl -I https://metrics.monlog.erahyar.com
```

### **Service Connectivity**
```bash
# Test internal connectivity
curl http://192.168.80.25:9090/-/healthy

# Test external routing
curl -u admin:password https://metrics.monlog.erahyar.com/-/healthy

# Test HTTPS redirect
curl -I http://metrics.monlog.erahyar.com
```

### **DNS Configuration**
```bash
# Verify DNS resolution
nslookup metrics.monlog.erahyar.com
nslookup grafana.monlog.erahyar.com

# Test from different locations
dig +short metrics.monlog.erahyar.com
```

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **503 Service Unavailable**
```bash
# Check if monitoring services are running
ssh deploy@192.168.80.25 "docker-compose ps"

# Verify network connectivity
telnet 192.168.80.25 9090

# Check Traefik logs
docker logs traefik
```

#### **SSL Certificate Issues**
```bash
# Check ACME challenge
curl http://metrics.monlog.erahyar.com/.well-known/acme-challenge/test

# Verify certificate storage
ls -la /data/acme.json

# Check certificate resolver logs
docker logs traefik | grep -i acme
```

#### **Authentication Problems**
```bash
# Test basic auth hash
echo "admin:{SHA}Ne0GBlaxUeH02aZ1+MabHvXMBv4=" | base64

# Verify middleware configuration
curl -u admin:wrong_password https://metrics.monlog.erahyar.com
```

## 📚 **Advanced Configuration**

### **Custom Middleware**
```yaml
# Rate limiting
http:
  middlewares:
    rate-limit:
      rateLimit:
        burst: 100
        average: 50
```

### **Load Balancing**
```yaml
# Multiple monitoring instances
http:
  services:
    prometheus:
      loadBalancer:
        servers:
          - url: "http://192.168.80.25:9090"
          - url: "http://192.168.80.26:9090"
        healthCheck:
          path: "/-/healthy"
          interval: 30s
```

### **Custom Headers**
```yaml
# Security headers
http:
  middlewares:
    security-headers:
      headers:
        customRequestHeaders:
          X-Forwarded-Proto: "https"
        customResponseHeaders:
          X-Content-Type-Options: "nosniff"
          X-Frame-Options: "DENY"
```

## 🎯 **Best Practices**

1. **🔒 Security**: Always use HTTPS in production
2. **📊 Monitoring**: Monitor Traefik metrics alongside your observability stack  
3. **🔄 Backup**: Keep backups of your Traefik configuration
4. **📱 Alerts**: Set up alerts for SSL certificate expiration
5. **🧪 Testing**: Test configuration changes in staging first

Your observability monitoring stack is now integrated with external Traefik! 🚀