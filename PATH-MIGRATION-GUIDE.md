# 🚀 Deployment Path Update Guide

## 📂 **Path Change Summary**

**OLD Path:** `/opt/observability`
**NEW Path:** `/opt/service/observability`

## ✅ **Files Updated**

### **1. GitLab CI/CD Pipeline (`.gitlab-ci.yml`):**
- Backup operations: `cd /opt/service/observability`
- Deployment target: `scp ... /opt/service/observability/`
- Service verification: `cd /opt/service/observability`

### **2. Documentation Files:**
- `DEPLOYMENT-GUIDE.md`: Server setup and deployment verification
- `GITLAB-SECURITY-SETUP.md`: Server preparation instructions
- `setup-gitlab-ci.sh`: Directory permission testing

## 🔧 **Production Server Migration**

### **Step 1: Backup Current Deployment**
```bash
# SSH to production server
ssh deploy@192.168.80.25

# Stop current services
cd /opt/observability
docker-compose down

# Create backup
sudo mkdir -p /opt/service
sudo cp -r /opt/observability /opt/service/observability
sudo chown -R deploy:deploy /opt/service/observability
```

### **Step 2: Update Directory Structure**
```bash
# On production server (192.168.80.25)
sudo mkdir -p /opt/service
sudo mv /opt/observability /opt/service/observability
sudo chown -R deploy:deploy /opt/service
sudo chmod -R 755 /opt/service
```

### **Step 3: Verify New Path**
```bash
# Test new directory access
cd /opt/service/observability
ls -la

# Test Docker Compose
docker-compose config
docker-compose up -d

# Verify services
docker-compose ps
```

## 🔒 **Updated GitLab Variables**

**No GitLab CI/CD variables need to be changed.** The deployment path is handled automatically by the pipeline.

## 📊 **Service Endpoints (Unchanged)**

Services will still be accessible at the same addresses:
- **Grafana**: http://192.168.80.25:3000
- **Prometheus**: http://192.168.80.25:9090  
- **AlertManager**: http://192.168.80.25:9093
- **Loki**: http://192.168.80.25:3100

## 🚀 **Automated Migration Script**

```bash
#!/bin/bash
# Server migration script - run on production server

echo "🔄 Migrating observability deployment to new path..."

# Stop services
cd /opt/observability
docker-compose down

# Create new directory structure
sudo mkdir -p /opt/service

# Move to new location
sudo mv /opt/observability /opt/service/observability

# Fix ownership
sudo chown -R deploy:deploy /opt/service
sudo chmod -R 755 /opt/service

# Start services in new location
cd /opt/service/observability
docker-compose up -d

# Verify
docker-compose ps
echo "✅ Migration completed successfully!"
```

## 🧪 **Testing New Deployment**

### **Local Testing:**
```bash
# Test GitLab CI/CD pipeline
git add .
git commit -m "feat: update deployment path to /opt/service/observability"
git push origin main
# → Monitor pipeline in GitLab UI
```

### **Manual Verification:**
```bash
# SSH to production
ssh deploy@192.168.80.25
cd /opt/service/observability

# Check services
make status
curl http://localhost:3000
curl http://localhost:9090
```

## 🔍 **Troubleshooting**

### **If Migration Fails:**
```bash
# Restore from old location
sudo cp -r /opt/observability.backup /opt/observability
cd /opt/observability
docker-compose up -d
```

### **Permission Issues:**
```bash
# Fix ownership
sudo chown -R deploy:deploy /opt/service/observability
sudo chmod -R 755 /opt/service/observability
```

### **Service Startup Issues:**
```bash
# Check logs
cd /opt/service/observability
docker-compose logs
docker-compose ps
```

## 📝 **Next Steps**

1. **Update Production Server**: Run the migration script above
2. **Test New Path**: Verify services work in new location  
3. **Deploy via GitLab**: Push changes to trigger automated deployment
4. **Monitor Services**: Ensure all endpoints are accessible

The deployment path has been updated to follow a more organized directory structure under `/opt/service/observability`! 🎯