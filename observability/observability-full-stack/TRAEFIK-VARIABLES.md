# Using Variables in Traefik Configuration

Since Traefik's static YAML files don't support environment variable substitution directly, I've created several solutions for you:

## 🔧 **Solution 1: Template + Script (Recommended)**

### Files Created:
- `traefik-config.template.yml` - Template with variables
- `generate-traefik-config.sh` - Script to process template
- `Makefile` - Easy management commands

### Usage:
```bash
# Generate config from your .env variables
./generate-traefik-config.sh

# Or use the Makefile
make config
```

### Variables Used:
- `${VM_IP}` - Your VM IP address (192.168.80.25)
- `${DOMAIN_ADDRESS}` - Your domain (monlog.erahyar.com)  
- `${WEB_AUTH_PASS}` - Your hashed password

## 🚀 **Quick Start with Makefile:**

```bash
# Show help
make help

# Start everything (auto-generates config)
make up

# Start only monitoring services
make up PROFILE=monitoring

# Stop services
make down

# Clean up everything
make clean

# Show logs
make logs
```

## 📝 **Manual Usage:**

### Generate Config:
```bash
# Load your .env variables and generate config
./generate-traefik-config.sh
```

### Start Services:
```bash
# Start with specific profile
docker-compose --profile observability up -d
```

## 🔄 **Automatic Workflow:**

The Makefile automatically:
1. ✅ Loads variables from `.env`
2. ✅ Generates `traefik-config.yml` from template  
3. ✅ Starts Docker Compose services
4. ✅ Shows access URLs

## 📋 **Benefits:**

### ✅ **Dynamic Configuration:**
- Change `VM_IP` in `.env` → regenerate config
- Update `DOMAIN_ADDRESS` → automatic URL updates
- Modify credentials → auth automatically updated

### ✅ **Easy Management:**
- Single command deployment: `make up`
- Profile-based service selection
- Automatic config generation
- Clean logging and status

### ✅ **Version Control Safe:**
- Template is generic (no sensitive data)
- Generated config can be gitignored
- Variables stay in `.env` (already gitignored)

## 🎯 **Recommended Workflow:**

1. **Edit** `.env` with your settings
2. **Run** `make up` to start everything  
3. **Access** services via IP or domain
4. **Update** `.env` and run `make config` to regenerate

This gives you the flexibility of variables while working within Traefik's limitations! 🚀