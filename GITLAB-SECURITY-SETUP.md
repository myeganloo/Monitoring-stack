# 🔐 GitLab CI/CD Security Variables Setup

This guide shows how to configure GitLab CI/CD variables with security best practices for the monitoring stack deployment.

## 🎯 **Security Variable Configuration**

### **Step 1: Access GitLab Variables**
1. Navigate to your GitLab project
2. Go to **Settings** → **CI/CD** → **Variables**
3. Click **Add Variable** for each configuration below

### **Step 2: Production Server Variables**
Add these variables with **Protected** flag (main branch only):

```bash
# Server Configuration (Protected: ✅, Masked: ❌)
PRODUCTION_HOST         = 192.168.80.25
PRODUCTION_VM_IP        = 192.168.80.25
PRODUCTION_DOMAIN       = monlog.erahyar.com
```

### **Step 3: Secure Authentication Variables**
Add these variables with **Masked** and **Protected** flags:

```bash
# SSH Connection (Protected: ✅, Masked: ✅)
SECURE_SSH_USER         = deploy
SECURE_SSH_PRIVATE_KEY  = <base64_encoded_private_key>
SECURE_SSH_HOST_KEY     = <ssh_host_key_from_keyscan>

# Application Credentials (Protected: ✅, Masked: ✅)
SECURE_GRAFANA_USERNAME = admin
SECURE_GRAFANA_PASSWORD = <strong_password>
SECURE_ACME_EMAIL      = admin@erahyar.com
SECURE_WEB_AUTH_USER   = admin
SECURE_WEB_AUTH_PASS   = <bcrypt_hashed_password>
```

### **Step 4: Optional Notification Variables**
```bash
# Slack Integration (Protected: ✅, Masked: ✅)
SECURE_SLACK_WEBHOOK_URL = https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

## 🔧 **SSH Key Generation Process**

### **Generate SSH Keys:**
```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/monitoring_deploy_key -N ""

# Copy public key to production server
ssh-copy-id -i ~/.ssh/monitoring_deploy_key.pub deploy@192.168.80.25

# Base64 encode private key for GitLab
base64 -w 0 ~/.ssh/monitoring_deploy_key
# Copy this output for SECURE_SSH_PRIVATE_KEY variable

# Get SSH host key
ssh-keyscan 192.168.80.25
# Copy this output for SECURE_SSH_HOST_KEY variable
```

### **Server Preparation:**
```bash
# On production server (192.168.80.25)
sudo useradd -m -s /bin/bash deploy
sudo usermod -aG docker deploy
sudo mkdir -p /opt/observability
sudo chown deploy:deploy /opt/observability
```

## 🚀 **GitLab Variable Setup Checklist**

### **Required Variables:**
- [ ] `PRODUCTION_HOST` (Protected)
- [ ] `PRODUCTION_VM_IP` (Protected)  
- [ ] `PRODUCTION_DOMAIN` (Protected)
- [ ] `SECURE_SSH_USER` (Masked & Protected)
- [ ] `SECURE_SSH_PRIVATE_KEY` (Masked & Protected)
- [ ] `SECURE_SSH_HOST_KEY` (Masked & Protected)
- [ ] `SECURE_GRAFANA_USERNAME` (Masked & Protected)
- [ ] `SECURE_GRAFANA_PASSWORD` (Masked & Protected)
- [ ] `SECURE_ACME_EMAIL` (Masked & Protected)
- [ ] `SECURE_WEB_AUTH_USER` (Masked & Protected)
- [ ] `SECURE_WEB_AUTH_PASS` (Masked & Protected)

### **Optional Variables:**
- [ ] `SECURE_SLACK_WEBHOOK_URL` (Masked & Protected)

## 🔒 **Security Best Practices**

### **Variable Naming Convention:**
- **`SECURE_*`** = Sensitive data (passwords, keys, tokens) - Always Masked & Protected
- **`PRODUCTION_*`** = Configuration data (IPs, domains) - Protected only
- **Never** use plain variable names for sensitive data

### **Protection Levels:**
- **Protected**: Variable only available to protected branches (main)
- **Masked**: Variable value hidden in job logs and output
- **Environment Scope**: Limit variables to specific environments

### **Password Security:**
- Use strong passwords (20+ characters)
- Hash basic auth passwords with bcrypt: `htpasswd -nbB admin your_password`
- Rotate passwords regularly
- Never commit passwords to code

## 📊 **Deployment Process**

### **Automatic Validation:**
```bash
# Push any branch for validation
git checkout -b feature/updates
git push origin feature/updates
# → Triggers validation pipeline only
```

### **Production Deployment:**
```bash
# Push main branch for production
git checkout main
git push origin main
# → Triggers full pipeline with manual production approval
```

### **Manual Approval:**
1. Pipeline runs validation, build, test, security stages automatically
2. Production deployment job waits for manual approval
3. Click **"Deploy to Production"** button in GitLab UI
4. Monitor deployment progress and health checks
5. Receive notification on completion (if Slack configured)

## 🩺 **Verification Commands**

### **Check Variable Setup:**
```bash
# In GitLab pipeline job, verify variables are loaded (values will be masked)
echo "SSH User: $SECURE_SSH_USER"
echo "Production Host: $PRODUCTION_HOST" 
echo "Grafana User: $SECURE_GRAFANA_USERNAME"
```

### **Test SSH Connection:**
```bash
# Test connection to production server
ssh -i ~/.ssh/monitoring_deploy_key deploy@192.168.80.25 "whoami && docker --version"
```

### **Verify Services:**
After deployment, check service endpoints:
- **Grafana**: http://192.168.80.25:3000
- **Prometheus**: http://192.168.80.25:9090  
- **AlertManager**: http://192.168.80.25:9093
- **Loki**: http://192.168.80.25:3100

## ⚠️ **Troubleshooting**

### **Common Issues:**
1. **SSH Connection Failed**: Check `SECURE_SSH_PRIVATE_KEY` is base64 encoded
2. **Permission Denied**: Ensure deploy user is in docker group
3. **Variables Not Found**: Check variable names match exactly (case-sensitive)
4. **Masked Variable Errors**: Verify sensitive data uses `SECURE_` prefix

### **Debug Commands:**
```bash
# Check variable availability (in pipeline)
env | grep -E "(PRODUCTION|SECURE)_" | sort

# Verify SSH key format
echo "$SECURE_SSH_PRIVATE_KEY" | base64 -d | ssh-keygen -lf -

# Test Docker on target server
ssh deploy@$PRODUCTION_HOST "docker ps"
```

## 🎉 **Ready to Deploy!**

Once all variables are configured:
1. Commit and push to main branch
2. Monitor pipeline in GitLab UI
3. Approve production deployment when ready
4. Verify services are running on http://192.168.80.25:3000

**Your observability monitoring stack is now ready for secure, automated deployment! 🚀**