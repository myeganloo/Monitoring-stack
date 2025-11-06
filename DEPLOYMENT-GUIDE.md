# GitLab CI/CD Deployment Guide

## 🚀 **Automated Deployment Pipeline**

This project includes a comprehensive GitLab CI/CD pipeline that automatically validates, tests, and deploys your observability monitoring stack across multiple environments.

## 📋 **Pipeline Overview**

### **Pipeline Stages:**
1. **🔍 Validate** - Syntax and configuration validation
2. **🔧 Build** - Generate environment-specific configs
3. **🧪 Test** - Docker Compose and endpoint testing
4. **🔒 Security** - Security scanning and best practices
5. **🚀 Deploy Staging** - Automated staging deployment
6. **🎯 Deploy Production** - Manual production deployment
7. **📢 Notify** - Success/failure notifications

### **Deployment Flow:**
```bash
main branch    → Production (manual approval only)
feature/*      → Validation & Testing only
```

## 🔐 **Required GitLab CI/CD Security Variables**

All sensitive data is now stored as **masked and protected** GitLab CI/CD variables with the `SECURE_` prefix for enhanced security.

### **🎯 Production Environment Variables:**
```bash
# Server Connection (Masked & Protected)
PRODUCTION_HOST=192.168.80.25               # Production server IP
SECURE_SSH_USER=deploy                      # SSH username (masked)
SECURE_SSH_PRIVATE_KEY=<base64_key>         # SSH private key (masked)
SECURE_SSH_HOST_KEY=<ssh_host_key>          # SSH host key (masked)

# Environment Configuration
PRODUCTION_VM_IP=192.168.80.25             # VM IP for services
PRODUCTION_DOMAIN=monlog.erahyar.com       # Production domain

# Application Credentials (All Masked & Protected)
SECURE_GRAFANA_USERNAME=admin               # Grafana admin user
SECURE_GRAFANA_PASSWORD=<secure_password>   # Grafana admin password
SECURE_ACME_EMAIL=admin@erahyar.com        # Let's Encrypt email
SECURE_WEB_AUTH_USER=admin                 # Basic auth username
SECURE_WEB_AUTH_PASS=<hashed_password>     # Basic auth password (SHA hash)
```

### **📢 Notification Variables (Optional):**
```bash
# Slack Integration (Masked & Protected)
SECURE_SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
```

### **🔒 Security Variable Naming Convention:**
- **`SECURE_*`** = Masked, Protected, Sensitive data
- **`PRODUCTION_*`** = Protected, Non-sensitive configuration
- All `SECURE_*` variables are automatically masked in logs

## 🔧 **GitLab Configuration Setup**

### **1. Add CI/CD Variables in GitLab:**
```bash
# Navigate to: Project → Settings → CI/CD → Variables
# Add each variable with appropriate protection and masking:

# Protected: ✅ (for main/develop branches only)
# Masked: ✅ (for sensitive data)
# Environment: staging/production (scope to specific environments)
```

### **2. Generate SSH Keys for Deployment:**

```bash
# Create deploy user on production server
sudo useradd -m -s /bin/bash deploy
sudo usermod -aG docker deploy

# Generate SSH key pair for deployment
ssh-keygen -t rsa -b 4096 -f ~/.ssh/monitoring_deploy_key

# Add public key to production server
ssh-copy-id -i ~/.ssh/monitoring_deploy_key.pub deploy@192.168.80.25

# Base64 encode private key for GitLab SECURE_SSH_PRIVATE_KEY variable
base64 -w 0 ~/.ssh/monitoring_deploy_key

# Get host key for SECURE_SSH_HOST_KEY variable
ssh-keyscan 192.168.80.25

# Example GitLab variable setup:
SECURE_SSH_USER="deploy"
SECURE_SSH_PRIVATE_KEY="<output_from_base64_command>"
SECURE_SSH_HOST_KEY="<output_from_ssh-keyscan>"
```

### **3. Prepare Production Server:**

```bash
# On production server (192.168.80.25)
sudo mkdir -p /opt/observability
sudo chown deploy:deploy /opt/observability
sudo chmod 755 /opt/observability

# Install required tools
sudo apt update
sudo apt install -y docker.io docker-compose make curl

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl start docker

# Add deploy user to docker group
sudo usermod -aG docker deploy
```

## 🚀 **Deployment Process**

### **Production Deployment:**

```bash
# Production deployment (manual approval required)
git checkout main
git add .
git commit -m "feat: update monitoring configuration"
git push origin main
# → Triggers validation pipeline
# → Requires manual approval in GitLab UI for deployment

# Feature development (validation only)
git checkout -b feature/new-dashboard
git add .
git commit -m "feat: add new dashboard"
git push origin feature/new-dashboard
# → Triggers validation and testing only (no deployment)
```

### **Manual Deployments:**
```bash
# In GitLab UI:
# 1. Go to CI/CD → Pipelines
# 2. Find your pipeline
# 3. Click "play" button on deploy:production job
# 4. Confirm deployment
```

## 🔍 **Pipeline Features**

### **✅ Validation Stage:**
- **Syntax Check**: Validates Docker Compose YAML syntax
- **Environment Template**: Ensures all required variables are present
- **Configuration Files**: Validates Prometheus, Loki, Alertmanager configs

### **✅ Build Stage:**
- **Environment Generation**: Creates `.env.production` with secure variables
- **Artifact Creation**: Packages deployment configurations
- **Version Tagging**: Creates deployment tags

### **✅ Test Stage:**
- **Compose Testing**: Tests Docker Compose configuration
- **Endpoint Validation**: Ensures all services have proper port exposure
- **Health Checks**: Basic service definition validation

### **✅ Security Stage:**
- **Secret Scanning**: Checks for hardcoded passwords
- **Default Credentials**: Ensures no default admin/admin credentials
- **TLS Configuration**: Validates SSL/TLS settings

### **✅ Deployment Features:**
- **Backup Creation**: Backs up current deployment before update
- **Rolling Deployment**: Graceful service updates
- **Health Verification**: Post-deployment health checks
- **Rollback Ready**: Easy rollback to previous version if needed

## 📊 **Monitoring Deployment**

### **Pipeline Status:**
- **GitLab UI**: Monitor pipeline progress in real-time
- **Notifications**: Slack notifications on success/failure
- **Environment URLs**: Direct links to deployed services

### **Service Health Checks:**
```bash
# After deployment, verify services:
curl -f http://$VM_IP:9090/-/healthy     # Prometheus
curl -f http://$VM_IP:3000/api/health    # Grafana
curl -f http://$VM_IP:9093/-/healthy     # Alertmanager
```

### **Deployment Verification:**
```bash
# SSH to deployed server
ssh deploy@$STAGING_HOST
cd /opt/observability

# Check service status
make status
docker-compose ps
docker-compose logs grafana

# Test service access
curl http://localhost:3000
```

## 🛠️ **Troubleshooting**

### **Common Pipeline Failures:**

#### **SSH Connection Issues:**
```bash
# Verify SSH key format
echo $SSH_PRIVATE_KEY | base64 -d | ssh-keygen -lf -

# Test SSH connection manually
ssh -i ~/.ssh/deploy_key deploy@$HOST_IP
```

#### **Environment Variable Missing:**
```bash
# Check GitLab variables are set
# Project → Settings → CI/CD → Variables
# Ensure variables are not expired and properly scoped
```

#### **Docker Issues:**
```bash
# On target server, check Docker status
sudo systemctl status docker
sudo docker ps
sudo docker-compose ps
```

#### **Service Health Failures:**
```bash
# Check service logs
docker-compose logs $SERVICE_NAME
# Check port binding
netstat -tlnp | grep $PORT
```

### **Rollback Procedure:**
```bash
# SSH to affected server
ssh deploy@$HOST

# Restore from backup
cd /opt/observability
make down
rm -rf current_deployment
mv backup current_deployment
cd current_deployment
make up
```

## 🎯 **Best Practices**

### **✅ Security:**
- **Rotate SSH keys** regularly
- **Use strong passwords** for all services
- **Enable 2FA** for GitLab access
- **Review permissions** regularly

### **✅ Operations:**
- **Test in staging** before production
- **Monitor deployments** actively
- **Keep backups** of working configurations
- **Document changes** in commit messages

### **✅ Maintenance:**
- **Update base images** regularly
- **Review pipeline performance** monthly
- **Clean up old artifacts** periodically
- **Update documentation** as needed

Your monitoring stack now has enterprise-grade CI/CD deployment capabilities! 🚀