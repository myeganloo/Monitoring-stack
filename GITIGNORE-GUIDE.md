# .gitignore Configuration Guide

## 📋 **Merged .gitignore Overview**

This project now uses a single, comprehensive `.gitignore` file located in the root directory that covers all components of the observability monitoring stack.

## 🔄 **What Was Merged**

### **Before:**
- `/monitoring/.gitignore` - Root level ignore file
- `/monitoring/observability/.gitignore` - Duplicate subdirectory ignore file

### **After:**
- ✅ **Single comprehensive `.gitignore`** in project root
- ❌ **Removed duplicate** from observability subdirectory
- 🚀 **Enhanced coverage** for all monitoring components

## 🛡️ **Protection Categories**

### **🔒 Security & Secrets:**
```gitignore
# Environment files with credentials
.env*
!.env.example

# SSL certificates and keys
*.pem, *.key, *.crt, *.cert
secrets/, certs/
```

### **📊 Observability Data:**
```gitignore
# Service data directories (auto-created by containers)
grafana/data/, grafana/logs/
prometheus/data/, prometheus/storage/
loki/data/, loki/chunks/
tempo/data/, tempo/wal/
alertmanager/data/
```

### **🐳 Docker & Infrastructure:**
```gitignore
# Docker overrides and volumes
docker-compose.override.yml
volumes/
Dockerfile.*
```

### **💻 Development Tools:**
```gitignore
# IDEs and editors
.vscode/, .idea/
*.swp, *.swo

# OS files
.DS_Store, Thumbs.db
```

### **📦 Dependencies & Build:**
```gitignore
# Node.js (for any JS tools)
node_modules/
dist/, build/

# Package manager files
package-lock.json, yarn.lock
```

## 🎯 **Key Features**

### ✅ **Comprehensive Coverage:**
- **All observability services** (Prometheus, Grafana, Loki, Tempo, etc.)
- **Multiple development environments** 
- **Security-first approach** (no credentials committed)
- **Cross-platform compatibility** (Windows, Mac, Linux)

### ✅ **Smart Patterns:**
- **Wildcard patterns** for data directories in any subdirectory
- **Negative patterns** to include example files (`.env.example`)
- **Tool-specific exclusions** for common development tools

### ✅ **Organized Structure:**
- **Clear sections** with descriptive comments
- **Logical grouping** of related file types
- **Easy maintenance** and updates

## 🔧 **Usage Examples**

### **What Gets Ignored:**
```bash
# These will be ignored
.env                                    # Environment variables
grafana/data/grafana.db                # Grafana database
prometheus/data/chunks_head/           # Prometheus data
loki/data/index/                       # Loki index files
temp/debug.log                         # Temporary logs
node_modules/                          # Dependencies
.vscode/settings.json                  # IDE settings
```

### **What Gets Committed:**
```bash
# These will be tracked
.env.example                           # Environment template
grafana/dashboards/                    # Dashboard definitions
prometheus/prometheus.yml              # Prometheus config
loki/loki.yml                         # Loki configuration
compose.yml                           # Docker Compose definition
Makefile                              # Project automation
```

## 📝 **Customization**

### **Adding New Patterns:**
If you need to ignore additional files, add them to the appropriate section:

```gitignore
# ===== YOUR CUSTOM SECTION =====
# Add your specific ignores here
your-custom-files/
*.your-extension
```

### **Including Specific Files:**
To force-include files that would otherwise be ignored:

```gitignore
# Force include specific files
!important-config.env
!data/sample-data.json
```

## 🚀 **Benefits of Single .gitignore**

### ✅ **Simplified Management:**
- **One file to maintain** instead of multiple
- **Consistent rules** across all subdirectories  
- **Easier updates** and modifications

### ✅ **Better Coverage:**
- **Project-wide protection** from root level
- **Subdirectory patterns** work automatically
- **No missed files** due to missing subdirectory ignores

### ✅ **Team Collaboration:**
- **Single source of truth** for ignore rules
- **Less confusion** about what's ignored where
- **Easier onboarding** for new team members

## 🔍 **Verification Commands**

### **Check What's Ignored:**
```bash
# See what would be ignored
git status --ignored

# Check specific file
git check-ignore -v path/to/file

# List all ignored files
git ls-files --others --ignored --exclude-standard
```

### **Test Patterns:**
```bash
# Test if a file would be ignored
git check-ignore filename.log
echo $?  # 0 = ignored, 1 = not ignored
```

Your monitoring stack now has a robust, single `.gitignore` file that protects all sensitive data and maintains a clean repository! 🎉