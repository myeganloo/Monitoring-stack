#!/bin/bash
# Production Server Migration Script
# Updates deployment path from /opt/observability to /opt/service/observability

set -e

echo "🚀 Starting observability deployment path migration..."

# Check if running as deploy user
if [ "$USER" != "deploy" ]; then
    echo "❌ This script should be run as the 'deploy' user"
    echo "Run: su - deploy"
    exit 1
fi

# Check if old directory exists
if [ ! -d "/opt/observability" ]; then
    echo "❌ /opt/observability directory not found"
    echo "Nothing to migrate. Exiting."
    exit 0
fi

echo "📂 Current directory structure:"
ls -la /opt/

echo "⏸️  Stopping current services..."
cd /opt/observability
if [ -f "compose.yml" ] || [ -f "docker-compose.yml" ]; then
    docker-compose down || true
else
    echo "⚠️  No compose file found in /opt/observability"
fi

echo "📁 Creating new directory structure..."
sudo mkdir -p /opt/service

echo "🔄 Moving deployment to new location..."
sudo mv /opt/observability /opt/service/observability

echo "🔐 Fixing ownership and permissions..."
sudo chown -R deploy:deploy /opt/service
sudo chmod -R 755 /opt/service

echo "🚀 Starting services in new location..."
cd /opt/service/observability

# Check which compose file exists
if [ -f "compose.yml" ]; then
    COMPOSE_FILE="compose.yml"
elif [ -f "docker-compose.yml" ]; then
    COMPOSE_FILE="docker-compose.yml"
else
    echo "❌ No compose file found in new location"
    exit 1
fi

echo "📋 Testing configuration..."
docker-compose -f $COMPOSE_FILE config > /dev/null
echo "✅ Configuration is valid"

echo "🔧 Starting all services..."
docker-compose -f $COMPOSE_FILE up -d

echo "⏳ Waiting for services to start..."
sleep 10

echo "🔍 Checking service status..."
docker-compose -f $COMPOSE_FILE ps

echo "🏥 Testing service endpoints..."
curl -f http://localhost:9090/-/healthy > /dev/null 2>&1 && echo "✅ Prometheus is healthy" || echo "⚠️  Prometheus health check failed"
curl -f http://localhost:3000/api/health > /dev/null 2>&1 && echo "✅ Grafana is healthy" || echo "⚠️  Grafana health check failed"
curl -f http://localhost:9093/-/healthy > /dev/null 2>&1 && echo "✅ AlertManager is healthy" || echo "⚠️  AlertManager health check failed"

echo ""
echo "🎉 Migration completed successfully!"
echo "📂 New deployment location: /opt/service/observability"
echo "🌐 Service endpoints:"
echo "   - Grafana: http://$(hostname -I | cut -d' ' -f1):3000"
echo "   - Prometheus: http://$(hostname -I | cut -d' ' -f1):9090"
echo "   - AlertManager: http://$(hostname -I | cut -d' ' -f1):9093"
echo ""
echo "📝 To rollback if needed:"
echo "   sudo mv /opt/service/observability /opt/observability"
echo "   cd /opt/observability && docker-compose up -d"