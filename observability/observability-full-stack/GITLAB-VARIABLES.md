# 🔧 GitLab CI/CD Variables Setup Guide

This guide explains how to configure GitLab CI/CD variables for the observability monitoring stack deployment.

## 📋 **Required GitLab Variables**

### **🔐 Security Variables (Masked & Protected)**

Set these variables as **Masked** and **Protected** in GitLab CI/CD settings:

| Variable Name | Type | Example Value | Description |
|---------------|------|---------------|-------------|
| `SSH_PRIVATE_KEY_RUNNER` | Masked | `-----BEGIN OPENSSH PRIVATE KEY-----...` | SSH private key for deployment |
| `GRAFANA_PASSWORD` | Masked | `SecurePassword123!` | Grafana admin password |
| `WEB_AUTH_PASS` | Masked | `{SHA}hashed_password` | Basic auth password hash |
| `SLACK_WEBHOOK_URL` | Masked | `https://hooks.slack.com/services/T.../B.../...` | Slack webhook URL |

### **🌐 Configuration Variables**

Set these as regular variables (not masked):

| Variable Name | Example Value | Description |
|---------------|---------------|-------------|
| `VM_IP` | `192.168.80.25` | Target VM IP address |
| `DOMAIN_ADDRESS` | `monlog.erahyar.com` | Base domain for services |
| `GRAFANA_USERNAME` | `admin` | Grafana admin username |
| `WEB_AUTH_USER` | `admin` | Basic auth username |
| `ACME_EMAIL` | `admin@erahyar.com` | Email for SSL certificates |
| `SLACK_CHANNEL` | `#alerts` | Slack channel for alerts |
| `HOSTNAME` | `observability` | Server hostname |
| `RESTART_POLICY` | `on-failure` | Docker restart policy |

### **🏷️ Optional Tag Variables**

Override Docker image tags if needed:

| Variable Name | Default Value | Description |
|---------------|---------------|-------------|
| `PROMETHEUS_TAG` | `v3.4.1` | Prometheus image tag |
| `GRAFANA_TAG` | `12.3.2` | Grafana image tag |
| `ALERTMANAGER_TAG` | `v0.29.1` | AlertManager image tag |
| `LOKI_TAG` | `3.3.2` | Loki image tag |

## 🛠️ **Setup Instructions**

### **Step 1: Navigate to GitLab Project Settings**
```
Your Project → Settings → CI/CD → Variables
```

### **Step 2: Add Security Variables (Masked)**
```bash
# 1. SSH Private Key
Variable: SSH_PRIVATE_KEY_RUNNER
Value: -----BEGIN OPENSSH PRIVATE KEY-----
[your private key content]
-----END OPENSSH PRIVATE KEY-----
Flags: ✅ Masked, ✅ Protected

# 2. Grafana Password  
Variable: GRAFANA_PASSWORD
Value: YourSecurePassword123!
Flags: ✅ Masked, ✅ Protected

# 3. Web Auth Password Hash
Variable: WEB_AUTH_PASS
Value: {SHA}Ne0GBlaxUeH02aZ1+MabHvXMBv4=
Flags: ✅ Masked, ✅ Protected

# 4. Slack Webhook URL
Variable: SLACK_WEBHOOK_URL
Value: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
Flags: ✅ Masked, ✅ Protected
```

### **Step 3: Add Configuration Variables**
```bash
# VM Configuration
VM_IP: 192.168.80.25
DOMAIN_ADDRESS: monlog.erahyar.com
HOSTNAME: observability

# Authentication
GRAFANA_USERNAME: admin
WEB_AUTH_USER: admin
ACME_EMAIL: admin@erahyar.com

# Slack Configuration  
SLACK_CHANNEL: #alerts

# Docker Configuration
RESTART_POLICY: on-failure
```

## 🔐 **Security Best Practices**

### **Password Hash Generation**
```bash
# Generate WEB_AUTH_PASS hash
echo "your_password" | htpasswd -s -n -i admin
# Output: admin:{SHA}Ne0GBlaxUeH02aZ1+MabHvXMBv4=
# Use only the hash part: {SHA}Ne0GBlaxUeH02aZ1+MabHvXMBv4=
```

### **SSH Key Setup**
```bash
# Generate new SSH key pair (if needed)
ssh-keygen -t rsa -b 4096 -C "gitlab-ci@monitoring" -f ~/.ssh/gitlab_monitoring

# Add public key to target server
ssh-copy-id -i ~/.ssh/gitlab_monitoring.pub deploy@192.168.80.25

# Use private key content for SSH_PRIVATE_KEY_RUNNER variable
cat ~/.ssh/gitlab_monitoring
```

### **Slack Webhook Setup**
1. Go to your Slack workspace
2. Create a new app or use existing one
3. Add Incoming Webhooks feature
4. Create webhook for your channel
5. Copy webhook URL to `SLACK_WEBHOOK_URL` variable

## 📁 **Variable Usage in CI/CD**

The GitLab CI/CD pipeline automatically uses these variables through:

### **Environment File Generation**
```yaml
before_script:
  - |
    cat > .env << EOF
    VM_IP=${VM_IP}
    DOMAIN_ADDRESS=${DOMAIN_ADDRESS}
    GRAFANA_PASSWORD=${GRAFANA_PASSWORD}
    WEB_AUTH_PASS=${WEB_AUTH_PASS}
    SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL}
    # ... other variables
    EOF
```

### **SSH Configuration**
```yaml
before_script:
  - mkdir -p ~/.ssh
  - echo "$SSH_PRIVATE_KEY_RUNNER" > ~/.ssh/id_rsa
  - chmod 600 ~/.ssh/id_rsa
  - ssh-keyscan -H ${VM_IP} >> ~/.ssh/known_hosts
```

## 🧪 **Testing Variables**

### **Check Variable Availability**
```bash
# In GitLab CI/CD pipeline
echo "Testing variable availability:"
echo "VM_IP: ${VM_IP}"
echo "DOMAIN_ADDRESS: ${DOMAIN_ADDRESS}"
echo "GRAFANA_USERNAME: ${GRAFANA_USERNAME}"
# Note: Masked variables won't show actual values in logs
```

### **Validate Environment Generation**
```bash
# Generate and check .env file
envsubst < .env.example > .env
echo "Generated .env file:"
cat .env | head -10
```

## 🔧 **Troubleshooting**

### **Common Issues**

#### **Missing Variables Error**
```bash
# Error: Variable not found
# Solution: Check variable name spelling in GitLab CI/CD settings
```

#### **SSH Connection Failed**  
```bash
# Error: Permission denied (publickey)
# Solution: Verify SSH_PRIVATE_KEY_RUNNER contains correct private key
```

#### **Masked Variable Empty**
```bash
# Error: Webhook URL empty in deployment
# Solution: Check SLACK_WEBHOOK_URL is properly masked and saved
```

## 📊 **Variable Management**

### **Environment-Specific Variables**
```yaml
# Different values for different environments
variables:
  VM_IP_STAGING: "192.168.80.20"
  VM_IP_PRODUCTION: "192.168.80.25"
  DOMAIN_STAGING: "staging.monlog.erahyar.com"  
  DOMAIN_PRODUCTION: "monlog.erahyar.com"
```

### **Branch-Specific Deployment**
```yaml
# Use different variables based on branch
deploy_staging:
  variables:
    VM_IP: ${VM_IP_STAGING}
    DOMAIN_ADDRESS: ${DOMAIN_STAGING}
  only:
    - develop

deploy_production:
  variables:
    VM_IP: ${VM_IP_PRODUCTION}
    DOMAIN_ADDRESS: ${DOMAIN_PRODUCTION}
  only:
    - main
```

## ✅ **Checklist**

Before running the CI/CD pipeline, ensure:

- [ ] All required variables are set in GitLab
- [ ] Sensitive variables are marked as **Masked** and **Protected**
- [ ] SSH key has access to target VM
- [ ] Slack webhook URL is valid
- [ ] Domain DNS points to VM IP
- [ ] VM firewall allows required ports

Your GitLab CI/CD variables are now properly configured! 🚀