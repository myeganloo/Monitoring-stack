# Observability Stack Service Endpoints

## VM Configuration
- **VM IP Address**: `192.168.80.25` (configured via `VM_IP` environment variable)
- **Network**: Private VM network
- **Access**: Direct IP access with port mapping

## Service Endpoints

### 📊 **Monitoring Services**

#### Prometheus - Metrics Collection & Querying
- **URL**: `http://192.168.80.25:9090`
- **Port**: `9090`
- **Description**: Prometheus metrics server and query interface
- **Authentication**: None (configure in external Traefik if needed)

#### Grafana - Visualization & Dashboards  
- **URL**: `http://192.168.80.25:3000`
- **Port**: `3000`
- **Description**: Grafana dashboards and visualization
- **Authentication**: Username/Password (see .env file)
  - Default: `erahyarmon` / `X9mK2nP7qR5wT8vY3zC6bN4jL1sF0dG9`

#### Alertmanager - Alert Management
- **URL**: `http://192.168.80.25:9093`
- **Port**: `9093`  
- **Description**: Prometheus Alertmanager interface
- **Authentication**: None (configure in external Traefik if needed)

#### Pushgateway - Metrics Push Gateway
- **URL**: `http://192.168.80.25:9091`
- **Port**: `9091`
- **Description**: Prometheus Pushgateway for batch jobs
- **Authentication**: None

### 📝 **Logging Services**

#### Loki - Log Aggregation
- **URL**: `http://192.168.80.25:3100`
- **Port**: `3100`
- **Description**: Loki log aggregation API
- **Authentication**: None (configure in external Traefik if needed)
- **API Endpoints**:
  - Query: `http://192.168.80.25:3100/loki/api/v1/query`
  - Push: `http://192.168.80.25:3100/loki/api/v1/push`

### 🔍 **Tracing Services**

#### Tempo - Distributed Tracing
- **Tempo UI**: `http://192.168.80.25:3200`
- **Jaeger Ingest**: `http://192.168.80.25:14268`
- **Tempo gRPC**: `http://192.168.80.25:9095` 
- **OTLP gRPC**: `http://192.168.80.25:4317`
- **OTLP HTTP**: `http://192.168.80.25:4318`
- **Zipkin**: `http://192.168.80.25:9411`

## 🚀 **Quick Access Dashboard**

Copy and bookmark these URLs for quick access:

```bash
# Monitoring
Prometheus:    http://192.168.80.25:9090
Grafana:       http://192.168.80.25:3000
Alertmanager:  http://192.168.80.25:9093
Pushgateway:   http://192.168.80.25:9091

# Logging  
Loki:          http://192.168.80.25:3100

# Tracing
Tempo:         http://192.168.80.25:3200
Jaeger:        http://192.168.80.25:14268
OTLP gRPC:     http://192.168.80.25:4317
OTLP HTTP:     http://192.168.80.25:4318
Zipkin:        http://192.168.80.25:9411
```

## 🔧 **Configuration**

### Changing VM IP Address
To change the VM IP address, update the `VM_IP` variable in the `.env` file:

```bash
# VM IP Address
VM_IP=192.168.80.25
```

### Service Profiles
Start different combinations of services using Docker Compose profiles:

```bash
# Full observability stack
docker-compose --profile observability up -d

# Only monitoring services
docker-compose --profile monitoring up -d  

# Only logging services
docker-compose --profile logging up -d

# Only tracing services  
docker-compose --profile tracing up -d
```

## 🔐 **Security Notes**

- **Internal Network**: Services are bound to VM IP for internal access
- **No Authentication**: Most services have no built-in auth (add via external Traefik)
- **Firewall**: Consider firewall rules for port access
- **TLS**: Add TLS termination via external Traefik or load balancer

## 🌐 **External Access via Traefik**

If using external Traefik, reference the provided configuration files:
- `traefik-config.yml` - Dynamic file configuration  
- `traefik-labels.txt` - Docker label configuration

Update the upstream server addresses in Traefik config to point to:
- `http://192.168.80.25:PORT` for each service