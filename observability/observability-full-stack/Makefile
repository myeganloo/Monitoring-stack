# Makefile for Observability Stack Management

.PHONY: help config up down logs clean traefik-config

# Default target
help:
	@echo "🚀 Observability Stack Management"
	@echo ""
	@echo "Available targets:"
	@echo "  help           - Show this help message"
	@echo "  config         - Generate traefik-config.yml from template"
	@echo "  up             - Start the observability stack"
	@echo "  down           - Stop the observability stack"
	@echo "  logs           - Follow logs from all services"
	@echo "  clean          - Stop and remove all containers and volumes"
	@echo "  traefik-config - Generate Traefik configuration only"
	@echo ""
	@echo "Profiles:"
	@echo "  make up PROFILE=monitoring    - Start only monitoring services"
	@echo "  make up PROFILE=logging       - Start only logging services"
	@echo "  make up PROFILE=tracing       - Start only tracing services"
	@echo "  make up PROFILE=observability - Start all services (default)"

# Load environment variables
include .env

# Generate traefik config from template
config traefik-config:
	@echo "🔧 Generating traefik-config.yml..."
	@./generate-traefik-config.sh
	@echo ""

# Start services with profile support
PROFILE ?= observability
up: config
	@echo "🚀 Starting observability stack with profile: $(PROFILE)"
	@docker-compose --profile $(PROFILE) up -d
	@echo ""
	@echo "✅ Services started! Access URLs:"
	@echo "  Direct VM Access:"
	@echo "    Prometheus:   http://$(VM_IP):9090"
	@echo "    Grafana:      http://$(VM_IP):3000"
	@echo "    Alertmanager: http://$(VM_IP):9093"
	@echo "    Pushgateway:  http://$(VM_IP):9091"
	@echo "    Loki:         http://$(VM_IP):3100"
	@echo "    Tempo:        http://$(VM_IP):3200"
	@echo ""
	@echo "  Domain Access (via external Traefik):"
	@echo "    Prometheus:   https://metrics.$(DOMAIN_ADDRESS)"
	@echo "    Grafana:      https://grafana.$(DOMAIN_ADDRESS)"
	@echo "    Alertmanager: https://alerts.$(DOMAIN_ADDRESS)"
	@echo "    Pushgateway:  https://pushgw.$(DOMAIN_ADDRESS)"
	@echo "    Loki:         https://loki.$(DOMAIN_ADDRESS)"

# Stop services
down:
	@echo "⏹️  Stopping observability stack..."
	@docker-compose down
	@echo "✅ Services stopped!"

# Show logs
logs:
	@echo "📋 Following logs from all services..."
	@docker-compose logs -f

# Clean up everything
clean:
	@echo "🧹 Cleaning up observability stack..."
	@docker-compose down -v --remove-orphans
	@echo "✅ Cleanup complete!"

# Show current status
status:
	@echo "📊 Observability Stack Status:"
	@docker-compose ps

# Deployment helpers
deploy-staging:
	@echo "🚀 Deploying to staging environment..."
	@if [ ! -f .env.staging ]; then echo "❌ .env.staging not found"; exit 1; fi
	@cp .env.staging .env
	@./generate-traefik-config.sh
	@make down || true
	@make up PROFILE=observability
	@echo "✅ Staging deployment completed"

deploy-production:
	@echo "🚀 Deploying to production environment..."
	@if [ ! -f .env.production ]; then echo "❌ .env.production not found"; exit 1; fi
	@cp .env.production .env
	@./generate-traefik-config.sh
	@echo "Creating backup..."
	@mkdir -p backup/$(shell date +%Y%m%d_%H%M%S)
	@docker-compose ps > backup/$(shell date +%Y%m%d_%H%M%S)/services-before-deploy.txt || true
	@make down
	@sleep 10
	@make up PROFILE=observability
	@sleep 30
	@echo "🔍 Running health checks..."
	@curl -f http://$(VM_IP):9090/-/healthy || echo "⚠️ Prometheus health check failed"
	@curl -f http://$(VM_IP):3000/api/health || echo "⚠️ Grafana health check failed"
	@echo "✅ Production deployment completed"

# Health check
health:
	@echo "🔍 Running health checks..."
	@echo "Prometheus: " && curl -s -o /dev/null -w "%{http_code}" http://$(VM_IP):9090/-/healthy || echo "Failed"
	@echo "Grafana: " && curl -s -o /dev/null -w "%{http_code}" http://$(VM_IP):3000/api/health || echo "Failed"
	@echo "Alertmanager: " && curl -s -o /dev/null -w "%{http_code}" http://$(VM_IP):9093/-/healthy || echo "Failed"

# Setup GitLab CI
setup-ci:
	@echo "🔧 Setting up GitLab CI/CD..."
	@cd ../../ && ./setup-gitlab-ci.sh