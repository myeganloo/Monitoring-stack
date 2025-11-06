#!/bin/bash

# Traefik Config Generator Script
# This script generates traefik-config.yml from your .env file variables

set -e

# Load environment variables from .env file
if [ -f .env ]; then
    echo "Loading environment variables from .env file..."
    set -o allexport
    source .env
    set +o allexport
else
    echo "Error: .env file not found!"
    echo "Please make sure you're running this script from the directory containing .env"
    exit 1
fi

# Check required variables
if [ -z "$VM_IP" ]; then
    echo "Error: VM_IP not set in .env file"
    exit 1
fi

if [ -z "$DOMAIN_ADDRESS" ]; then
    echo "Error: DOMAIN_ADDRESS not set in .env file"
    exit 1
fi

if [ -z "$WEB_AUTH_PASS" ]; then
    echo "Error: WEB_AUTH_PASS not set in .env file"
    exit 1
fi

echo "Generating traefik-config.yml with:"
echo "  VM_IP: $VM_IP"
echo "  DOMAIN_ADDRESS: $DOMAIN_ADDRESS"
echo "  WEB_AUTH_USER: $WEB_AUTH_USER"

# Generate the config file
envsubst < traefik-config.template.yml > traefik-config.yml

echo "✅ traefik-config.yml generated successfully!"
echo ""
echo "Service URLs will be:"
echo "  Prometheus:   https://metrics.$DOMAIN_ADDRESS → http://$VM_IP:9090"
echo "  Grafana:      https://grafana.$DOMAIN_ADDRESS → http://$VM_IP:3000"
echo "  Alertmanager: https://alerts.$DOMAIN_ADDRESS → http://$VM_IP:9093"
echo "  Pushgateway:  https://pushgw.$DOMAIN_ADDRESS → http://$VM_IP:9091"
echo "  Loki:         https://loki.$DOMAIN_ADDRESS → http://$VM_IP:3100"