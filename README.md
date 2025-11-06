# 🔍 Observability & Monitoring Stack

A comprehensive monitoring, logging, and tracing solution deployed on private VM infrastructure with dual Git repository management.

## 🏗️ **Architecture Overview**

This project provides a complete observability stack including:
- **Monitoring**: Prometheus, Grafana, Alertmanager, Pushgateway
- **Logging**: Loki, Promtail
- **Tracing**: Tempo, Jaeger, Zipkin, OTLP
- **System Metrics**: Node Exporter, cAdvisor, Blackbox Exporter
- **Load Testing**: K6 with tracing support

## 🚀 **Quick Start**

```bash
# Clone the repository
git clone https://github.com/myeganloo/Monitoring-stack.git
cd monitoring

# Start the full observability stack
make up

# Or start specific services
make up PROFILE=monitoring    # Only monitoring services
make up PROFILE=logging       # Only logging services
make up PROFILE=tracing       # Only tracing services
```

## 🌐 **Service Access**

**Direct VM Access (192.168.80.25):**
- Prometheus: `http://192.168.80.25:9090`
- Grafana: `http://192.168.80.25:3000`
- Alertmanager: `http://192.168.80.25:9093`
- Loki: `http://192.168.80.25:3100`
- Tempo: `http://192.168.80.25:3200`

**Domain Access (via Traefik):**
- Prometheus: `https://metrics.monlog.erahyar.com`
- Grafana: `https://grafana.monlog.erahyar.com`
- Alertmanager: `https://alerts.monlog.erahyar.com`

## 🔧 **Git Repository Management**

This project uses **dual Git remotes** for enhanced collaboration:

```bash
# Primary remote (origin)
origin: https://git.erahyar.com/rahyar/monitoring.git

# Secondary remote 
secondary: https://github.com/myeganloo/Monitoring-stack.git
```

### **Git Management Commands:**
```bash
# Show repository status and remotes
./git-remote-manager.sh status

# Sync with all remotes
./git-remote-manager.sh sync  

# Push to both remotes
./git-remote-manager.sh push

# Push specific branch to both remotes
./git-remote-manager.sh push feature-branch
```

## 📁 **Project Structure**

