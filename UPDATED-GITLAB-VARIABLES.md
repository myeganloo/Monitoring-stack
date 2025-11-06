# 🔐 Updated GitLab CI/CD Variables List

## 📝 **Complete Variable Configuration**

Here are **ALL** the variables you need to create in your GitLab project with the updated SSH key variable name:

### 📍 **How to Add Variables:**
1. Go to your GitLab project
2. Navigate to: **Settings** → **CI/CD** → **Variables** 
3. Click **"Add Variable"** for each variable below

---

## 🎯 **Production Server Configuration**
**(Protected: ✅, Masked: ❌)**

```bash
# Variable 1:
Key: PRODUCTION_HOST
Value: 192.168.80.25
Flags: ✅ Protected ❌ Masked

# Variable 2: 
Key: PRODUCTION_VM_IP
Value: 192.168.80.25
Flags: ✅ Protected ❌ Masked

# Variable 3:
Key: PRODUCTION_DOMAIN  
Value: monlog.erahyar.com
Flags: ✅ Protected ❌ Masked
```

---

## 🔒 **SSH Connection Variables** 
**(Protected: ✅, Masked: ✅)**

```bash
# Variable 4:
Key: SECURE_SSH_USER
Value: deploy
Flags: ✅ Protected ✅ Masked

# Variable 5: ⚡ UPDATED - New SSH Key Variable
Key: SSH_PRIVATE_KEY_RUNNER
Value: <your_base64_encoded_private_key>
Flags: ✅ Protected ✅ Masked

# Variable 6:
Key: SECURE_SSH_HOST_KEY  
Value: <your_ssh_host_key>
Flags: ✅ Protected ✅ Masked
```

---

## 🎛️ **Application Credentials**
**(Protected: ✅, Masked: ✅)**

```bash
# Variable 7:
Key: SECURE_GRAFANA_USERNAME
Value: admin
Flags: ✅ Protected ✅ Masked

# Variable 8:
Key: SECURE_GRAFANA_PASSWORD
Value: <your_strong_password>
Flags: ✅ Protected ✅ Masked

# Variable 9:
Key: SECURE_ACME_EMAIL
Value: admin@erahyar.com  
Flags: ✅ Protected ✅ Masked

# Variable 10:
Key: SECURE_WEB_AUTH_USER
Value: admin
Flags: ✅ Protected ✅ Masked

# Variable 11:
Key: SECURE_WEB_AUTH_PASS
Value: <your_hashed_password>
Flags: ✅ Protected ✅ Masked
```

---

## 📢 **Slack Notification**
**(Protected: ✅, Masked: ✅)**

```bash
# Variable 12:
Key: SECURE_SLACK_WEBHOOK_URL
Value: https://hooks.slack.com/services/YOUR/ACTUAL/WEBHOOK_URL
Flags: ✅ Protected ✅ Masked
```

---

## ⚡ **What Changed:**

### **OLD SSH Variable:**
```bash
❌ SECURE_SSH_PRIVATE_KEY  # Old variable name
```

### **NEW SSH Variable:**
```bash
✅ SSH_PRIVATE_KEY_RUNNER   # New variable name (Standard GitLab CI naming)
```

### **Why This Change:**
- **Standard Convention**: `SSH_PRIVATE_KEY_RUNNER` follows GitLab CI/CD naming conventions
- **Cleaner Naming**: More descriptive for runner-specific SSH keys
- **Better Organization**: Separates deployment SSH keys from other secure variables

---

## 🔧 **SSH Key Generation (Updated Commands):**

```bash
# Generate SSH key for deployment
ssh-keygen -t rsa -b 4096 -f ~/.ssh/monitoring_deploy_key -N ""

# Copy public key to server
ssh-copy-id -i ~/.ssh/monitoring_deploy_key.pub deploy@192.168.80.25

# Get base64 private key for SSH_PRIVATE_KEY_RUNNER variable
base64 -w 0 ~/.ssh/monitoring_deploy_key

# Get host key for SECURE_SSH_HOST_KEY variable
ssh-keyscan 192.168.80.25

# Example GitLab variable setup:
SSH_PRIVATE_KEY_RUNNER="<output_from_base64_command>"
SECURE_SSH_HOST_KEY="<output_from_ssh-keyscan>"
```

---

## 📊 **Variable Summary:**
- **Total Variables**: 12
- **Changed Variables**: 1 (SSH key variable renamed)
- **Protected Variables**: 12 (all variables)
- **Masked Variables**: 9 (all SECURE_* and SSH_PRIVATE_KEY_RUNNER)

---

## 🚀 **Next Steps:**

1. **Update/Create GitLab Variables**: Use the new `SSH_PRIVATE_KEY_RUNNER` variable name
2. **Test SSH Connection**: Verify the SSH key works with the new variable
3. **Deploy**: Run the GitLab CI/CD pipeline
4. **Verify**: Check that AlertManager sends Slack notifications

The GitLab CI/CD pipeline has been updated to use `SSH_PRIVATE_KEY_RUNNER` instead of `SECURE_SSH_PRIVATE_KEY` for better naming consistency! 🎯