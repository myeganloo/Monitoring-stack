#!/bin/bash
#
# Traefik Configuration Generator
# Generates Traefik configuration files for external Traefik proxy integration
#
# This script processes the traefik-config.template.yml file and generates
# both the actual config file and Docker Compose labels for services.
#
# Author: Monitoring Stack Project
# Version: 2.0
# Date: November 2025

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${SCRIPT_DIR}/traefik-config.template.yml"
OUTPUT_FILE="${SCRIPT_DIR}/traefik-config.yml"
LABELS_FILE="${SCRIPT_DIR}/traefik-labels.txt"
ENV_FILE="${SCRIPT_DIR}/.env"
ENV_EXAMPLE="${SCRIPT_DIR}/.env.example"

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}"
    echo "==============================================="
    echo "  Traefik Configuration Generator v2.0"
    echo "==============================================="
    echo -e "${NC}"
}

# Check if required files exist
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    if [ ! -f "$TEMPLATE_FILE" ]; then
        print_error "Template file not found: $TEMPLATE_FILE"
        exit 1
    fi
    
    if [ ! -f "$ENV_EXAMPLE" ]; then
        print_error "Environment example file not found: $ENV_EXAMPLE"
        exit 1
    fi
    
    # Check if envsubst is available
    if ! command -v envsubst &> /dev/null; then
        print_error "envsubst command not found. Please install gettext-base package:"
        print_error "  Ubuntu/Debian: sudo apt install gettext-base"
        print_error "  CentOS/RHEL: sudo yum install gettext"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Load environment variables
load_environment() {
    print_info "Loading environment variables..."
    
    # Check if .env file exists
    if [ -f "$ENV_FILE" ]; then
        print_info "Using existing .env file"
        set -o allexport
        source "$ENV_FILE"
        set +o allexport
    else
        print_warning ".env file not found. Creating from .env.example"
        cp "$ENV_EXAMPLE" "$ENV_FILE"
        print_warning "Please edit $ENV_FILE with your configuration and run the script again"
        exit 1
    fi
    
    # Validate required variables
    local required_vars=(
        "VM_IP"
        "DOMAIN_ADDRESS"
        "WEB_AUTH_PASS"
        "PROMETHEUS_SUB"
        "GRAFANA_SUB"
        "ALERTMANAGER_SUB"
        "PUSHGATEWAY_SUB"
        "LOKI_SUB"
    )
    
    local missing_vars=()
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ] || [ "${!var}" = "your-domain.com" ] || [ "${!var}" = "192.168.x.x" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_error "Missing or default values found for required variables:"
        for var in "${missing_vars[@]}"; do
            print_error "  - $var"
        done
        print_error "Please update $ENV_FILE with proper values"
        exit 1
    fi
    
    print_success "Environment variables loaded successfully"
}

# Generate Traefik configuration file
generate_config_file() {
    print_info "Generating Traefik configuration file..."
    
    # Export variables for envsubst
    export VM_IP
    export DOMAIN_ADDRESS
    export WEB_AUTH_PASS
    export PROMETHEUS_SUB
    export GRAFANA_SUB
    export ALERTMANAGER_SUB
    export PUSHGATEWAY_SUB
    export LOKI_SUB
    
    # Process template
    envsubst < "$TEMPLATE_FILE" > "$OUTPUT_FILE"
    
    if [ $? -eq 0 ]; then
        print_success "Configuration file generated: $OUTPUT_FILE"
    else
        print_error "Failed to generate configuration file"
        exit 1
    fi
}

# Validate generated configuration
validate_configuration() {
    print_info "Validating generated configuration..."
    
    # Check if file was created and is not empty
    if [ ! -s "$OUTPUT_FILE" ]; then
        print_error "Generated configuration file is empty or missing"
        exit 1
    fi
    
    # Basic YAML syntax check (if yq is available)
    if command -v yq &> /dev/null; then
        if yq eval '.' "$OUTPUT_FILE" > /dev/null 2>&1; then
            print_success "YAML syntax validation passed"
        else
            print_error "YAML syntax validation failed"
            exit 1
        fi
    else
        print_warning "yq not available, skipping YAML syntax validation"
    fi
    
    # Check for required sections
    local required_sections=("http.routers" "http.services" "http.middlewares")
    for section in "${required_sections[@]}"; do
        if grep -q "$section" "$OUTPUT_FILE"; then
            print_info "✓ Found section: $section"
        else
            print_warning "⚠ Section not found: $section"
        fi
    done
}

# Generate Docker Compose labels file
generate_labels_file() {
    print_info "Updating Docker Compose labels file..."
    
    # The labels file is already generated, but we can update it with current values
    if [ -f "$LABELS_FILE" ]; then
        # Create a temporary file with updated values
        local temp_file=$(mktemp)
        # Replace placeholder values in labels file
        sed "s/\${DOMAIN_ADDRESS}/$DOMAIN_ADDRESS/g" "$LABELS_FILE" > "$temp_file"
        mv "$temp_file" "$LABELS_FILE"
        print_success "Labels file updated with current domain"
    else
        print_warning "Labels file not found: $LABELS_FILE"
    fi
}

# Show configuration summary
show_summary() {
    print_info "Configuration Summary:"
    echo "  Domain: $DOMAIN_ADDRESS"
    echo "  VM IP: $VM_IP"
    echo "  Services:"
    echo "    - Prometheus: https://${PROMETHEUS_SUB}.${DOMAIN_ADDRESS}"
    echo "    - Grafana: https://${GRAFANA_SUB}.${DOMAIN_ADDRESS}"
    echo "    - AlertManager: https://${ALERTMANAGER_SUB}.${DOMAIN_ADDRESS}"
    echo "    - Pushgateway: https://${PUSHGATEWAY_SUB}.${DOMAIN_ADDRESS}"
    echo "    - Loki: https://${LOKI_SUB}.${DOMAIN_ADDRESS}"
    echo ""
    echo "Generated files:"
    echo "  - $OUTPUT_FILE"
    echo "  - $LABELS_FILE"
}

# Show usage instructions
show_usage() {
    print_info "Usage Instructions:"
    echo ""
    echo "1. External Traefik (File Provider):"
    echo "   Copy $OUTPUT_FILE to your Traefik dynamic configuration directory"
    echo "   Example: cp $OUTPUT_FILE /etc/traefik/dynamic/"
    echo ""
    echo "2. External Traefik (Docker Provider):"
    echo "   Add the labels from $LABELS_FILE to your Docker Compose services"
    echo ""
    echo "3. Verify your Traefik instance has the following middlewares configured:"
    echo "   - web-auth (basic authentication)"
    echo "   - https-redirect (HTTP to HTTPS redirect)"
    echo ""
    echo "4. Ensure your Traefik instance has a cert resolver named 'mycert'"
}

# Main function
main() {
    print_header
    
    check_prerequisites
    load_environment
    generate_config_file
    validate_configuration
    generate_labels_file
    
    echo ""
    show_summary
    echo ""
    show_usage
    
    print_success "Traefik configuration generation completed successfully!"
}

# Script help
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Traefik Configuration Generator"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --version  Show version information"
    echo ""
    echo "This script generates Traefik configuration files for external proxy integration."
    echo "It processes traefik-config.template.yml using environment variables from .env file."
    echo ""
    echo "Required files:"
    echo "  - traefik-config.template.yml (template file)"
    echo "  - .env (environment variables)"
    echo "  - .env.example (environment template)"
    echo ""
    echo "Generated files:"
    echo "  - traefik-config.yml (processed configuration)"
    echo "  - traefik-labels.txt (Docker Compose labels)"
    exit 0
fi

if [ "$1" = "-v" ] || [ "$1" = "--version" ]; then
    echo "Traefik Configuration Generator v2.0"
    echo "Part of Observability Monitoring Stack"
    exit 0
fi

# Run main function
main "$@"