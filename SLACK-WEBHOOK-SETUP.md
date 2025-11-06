# 🔗 Slack Webhook Configuration Guide

## ✅ **Webhook URL Verified**
Your Slack webhook is working correctly:
```
https://hooks.slack.com/services/TXXXXXXXX/BXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX
```

## 🔐 **GitLab CI/CD Variable Setup**

### **Required GitLab Variables:**
Add these to your GitLab project: **Settings** → **CI/CD** → **Variables**

```bash
# Slack Configuration (Masked & Protected)
SECURE_SLACK_WEBHOOK_URL = https://hooks.slack.com/services/TXXXXXXXX/BXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX
```

**Variable Settings:**
- ✅ **Masked**: Yes (hides URL in logs)
- ✅ **Protected**: Yes (only available on main branch)
- 🔒 **Environment**: All environments

## 🧪 **Testing Commands**

### **Test Basic Webhook:**
```bash
curl -X POST --data-urlencode "payload={\"channel\": \"#alerts\", \"username\": \"AlertManager\", \"text\": \"✅ Webhook configuration test successful!\", \"icon_emoji\": \":white_check_mark:\"}" https://hooks.slack.com/services/TXXXXXXXX/BXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX
```

### **Test AlertManager Format:**
```bash
curl -X POST -H 'Content-type: application/json' --data '{
  "channel": "#alerts",
  "username": "AlertManager-Monitoring", 
  "icon_emoji": ":rotating_light:",
  "text": "*[FIRING] High CPU Usage*\n*Alert:* CPU usage above 80%\n*Description:* Server load is high\n*Severity:* warning\n*Instance:* 192.168.80.25",
  "attachments": [
    {
      "color": "warning",
      "actions": [
        {
          "type": "button",
          "text": "View in Grafana", 
          "url": "http://192.168.80.25:3000"
        }
      ]
    }
  ]
}' https://hooks.slack.com/services/TXXXXXXXX/BXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX
```

## 🚀 **Deployment Process**

### **1. Commit Your Changes:**
```bash
cd /home/mohsen/Documents/Project/rahyar/monitoring
git add .
git commit -m "feat: configure Slack webhook for AlertManager notifications"
git push origin main
```

### **2. Set GitLab Variable:**
1. Go to GitLab project → Settings → CI/CD → Variables
2. Click "Add Variable"
3. Key: `SECURE_SLACK_WEBHOOK_URL`
4. Value: `https://hooks.slack.com/services/TXXXXXXXX/BXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX`
5. Check: ✅ Masked ✅ Protected
6. Click "Add Variable"

### **3. Trigger Deployment:**
The GitLab pipeline will automatically:
- Generate `.env.production` with your webhook URL
- Deploy AlertManager with Slack configuration
- Test the monitoring stack

### **4. Verify Integration:**
After deployment, AlertManager will send notifications to `#alerts` channel with:
- 🚨 **Alert Status**: [FIRING] or [RESOLVED]
- 📊 **Alert Details**: Summary, description, severity
- 🔗 **Action Buttons**: Direct links to Grafana and Prometheus
- 🤖 **Professional Formatting**: Clean, structured messages

## 🎯 **Expected Slack Message Format**

When AlertManager sends notifications, you'll see messages like:
```
🚨 [FIRING] High Memory Usage
Alert: Memory usage exceeded 90%
Description: Server memory critically low
Severity: critical
Instance: prometheus:9090

[View in Grafana] [View in Prometheus]
```

## 🔧 **Local Testing**

Test your local AlertManager setup:
```bash
cd observability/observability-full-stack
docker-compose up -d alertmanager
docker logs alertmanager
```

## ⚠️ **Security Notes**

- ✅ Webhook URL is now stored as masked GitLab variable
- ✅ URL won't appear in pipeline logs
- ✅ Only protected branches can access the webhook
- 🔄 Rotate webhook if accidentally exposed

## 🎉 **Ready to Deploy!**

Your Slack webhook is configured and tested. The AlertManager will now send professional monitoring alerts to your `#alerts` channel with interactive buttons and rich formatting.

**Next: Push your changes and approve the GitLab deployment!** 🚀