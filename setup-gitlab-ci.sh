#!/bin/bash

# GitLab CI/CD Setup Assistant
# Helps configure GitLab variables and SSH keys for deployment

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE} GitLab CI/CD Setup Assistant${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_section() {
    echo -e "${BLUE}[SECTION]${NC} $1"
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to generate SSH keys
generate_ssh_keys() {
    print_section "SSH Key Generation"
    
    read -p "Enter path for SSH key (default: ./deploy_key): " ssh_path
    ssh_path=${ssh_path:-./deploy_key}
    
    if [ -f "$ssh_path" ]; then
        print_warning "SSH key already exists at $ssh_path"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping SSH key generation"
            return
        fi
    fi
    
    print_info "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f "$ssh_path" -N "" -C "gitlab-deploy-$(date +%Y%m%d)"
    
    print_info "SSH key generated successfully!"
    echo ""
    echo "Public key (add to target servers):"
    echo "----------------------------------------"
    cat "${ssh_path}.pub"
    echo "----------------------------------------"
    echo ""
    
    print_info "Base64 encoded private key (for GitLab CI variable):"
    echo "----------------------------------------"
    base64 -w 0 "$ssh_path"
    echo ""
    echo "----------------------------------------"
}

# Function to get host keys
get_host_keys() {
    print_section "SSH Host Key Collection"
    
    read -p "Enter staging server IP/hostname: " staging_host
    read -p "Enter production server IP/hostname: " prod_host
    
    if [ -n "$staging_host" ]; then
        print_info "Getting host key for staging server..."
        echo "Staging host key (for GitLab CI variable STAGING_HOST_KEY):"
        echo "----------------------------------------"
        ssh-keyscan "$staging_host" 2>/dev/null || print_error "Could not connect to $staging_host"
        echo "----------------------------------------"
        echo ""
    fi
    
    if [ -n "$prod_host" ]; then
        print_info "Getting host key for production server..."
        echo "Production host key (for GitLab CI variable PRODUCTION_HOST_KEY):"
        echo "----------------------------------------"
        ssh-keyscan "$prod_host" 2>/dev/null || print_error "Could not connect to $prod_host"
        echo "----------------------------------------"
        echo ""
    fi
}

# Function to generate password hashes
generate_password_hash() {
    print_section "Password Hash Generation"
    
    read -p "Enter username for basic auth: " username
    read -s -p "Enter password: " password
    echo ""
    
    # Generate SHA hash for basic auth
    hash=$(echo -n "$password" | sha1sum | cut -d' ' -f1 | xxd -r -p | base64)
    
    print_info "Basic auth hash (for GitLab CI variable WEB_AUTH_PASS):"
    echo "----------------------------------------"
    echo "{SHA}$hash"
    echo "----------------------------------------"
    echo ""
}

# Function to create GitLab variables template
create_gitlab_variables() {
    print_section "GitLab Variables Template"
    
    cat > gitlab-variables.md << 'EOF'
# GitLab CI/CD Variables Configuration

Copy these variables to your GitLab project:
**Project → Settings → CI/CD → Variables**

## Staging Environment Variables

| Variable Name | Value | Protected | Masked | Environment |
|---------------|--------|-----------|--------|-------------|
| STAGING_HOST | 192.168.80.25 | ✅ | ❌ | staging |
| STAGING_USER | deploy | ✅ | ❌ | staging |
| STAGING_SSH_PRIVATE_KEY | [base64 encoded key] | ✅ | ✅ | staging |
| STAGING_HOST_KEY | [ssh host key] | ✅ | ❌ | staging |
| STAGING_VM_IP | 192.168.80.25 | ✅ | ❌ | staging |
| STAGING_DOMAIN | staging.monlog.erahyar.com | ✅ | ❌ | staging |

## Production Environment Variables

| Variable Name | Value | Protected | Masked | Environment |
|---------------|--------|-----------|--------|-------------|
| PRODUCTION_HOST | 192.168.80.26 | ✅ | ❌ | production |
| PRODUCTION_USER | deploy | ✅ | ❌ | production |
| PRODUCTION_SSH_PRIVATE_KEY | [base64 encoded key] | ✅ | ✅ | production |
| PRODUCTION_HOST_KEY | [ssh host key] | ✅ | ❌ | production |
| PRODUCTION_VM_IP | 192.168.80.26 | ✅ | ❌ | production |
| PRODUCTION_DOMAIN | monlog.erahyar.com | ✅ | ❌ | production |

## Application Variables (Both Environments)

| Variable Name | Value | Protected | Masked | Environment |
|---------------|--------|-----------|--------|-------------|
| GRAFANA_USERNAME | admin | ✅ | ❌ | All |
| GRAFANA_PASSWORD | [secure password] | ✅ | ✅ | All |
| ACME_EMAIL | admin@erahyar.com | ✅ | ❌ | All |
| WEB_AUTH_USER | admin | ✅ | ❌ | All |
| WEB_AUTH_PASS | {SHA}[hashed password] | ✅ | ✅ | All |

## Optional Variables

| Variable Name | Value | Protected | Masked | Environment |
|---------------|--------|-----------|--------|-------------|
| SLACK_WEBHOOK_URL | https://hooks.slack.com/... | ✅ | ✅ | All |

## Variable Settings:
- **Protected**: ✅ (Only available to protected branches - main, develop)
- **Masked**: ✅ (For sensitive data - passwords, keys)
- **Environment**: Scope variables to specific environments when possible
EOF

    print_info "GitLab variables template created: gitlab-variables.md"
}

# Function to test server connectivity
test_server_setup() {
    print_section "Server Connectivity Test"
    
    read -p "Enter server IP to test: " test_host
    read -p "Enter SSH username: " test_user
    read -p "Enter path to SSH private key: " test_key
    
    if [ ! -f "$test_key" ]; then
        print_error "SSH key file not found: $test_key"
        return 1
    fi
    
    print_info "Testing SSH connectivity..."
    if ssh -i "$test_key" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$test_user@$test_host" "echo 'SSH connection successful'"; then
        print_info "✅ SSH connection successful"
    else
        print_error "❌ SSH connection failed"
        return 1
    fi
    
    print_info "Testing Docker availability..."
    if ssh -i "$test_key" -o StrictHostKeyChecking=no "$test_user@$test_host" "docker --version"; then
        print_info "✅ Docker is available"
    else
        print_error "❌ Docker not found or not accessible"
    fi
    
    print_info "Testing directory permissions..."
    if ssh -i "$test_key" -o StrictHostKeyChecking=no "$test_user@$test_host" "mkdir -p /opt/observability/test && rmdir /opt/observability/test"; then
        print_info "✅ Directory permissions are correct"
    else
        print_error "❌ Cannot write to /opt/observability/"
    fi
}

# Main menu
show_menu() {
    echo ""
    print_section "Setup Options"
    echo "1. Generate SSH keys for deployment"
    echo "2. Get SSH host keys from servers"
    echo "3. Generate password hash for basic auth"
    echo "4. Create GitLab variables template"
    echo "5. Test server connectivity and setup"
    echo "6. All setup steps (1-4)"
    echo "7. Exit"
    echo ""
}

# Main script execution
main() {
    print_header
    
    while true; do
        show_menu
        read -p "Select option (1-7): " choice
        
        case $choice in
            1)
                generate_ssh_keys
                ;;
            2)
                get_host_keys
                ;;
            3)
                generate_password_hash
                ;;
            4)
                create_gitlab_variables
                ;;
            5)
                test_server_setup
                ;;
            6)
                generate_ssh_keys
                get_host_keys
                generate_password_hash
                create_gitlab_variables
                print_info "🎉 Setup completed! Check the generated files and configure GitLab variables."
                ;;
            7)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-7."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    command -v ssh-keygen >/dev/null 2>&1 || missing_deps+=("ssh-keygen")
    command -v ssh-keyscan >/dev/null 2>&1 || missing_deps+=("ssh-keyscan") 
    command -v base64 >/dev/null 2>&1 || missing_deps+=("base64")
    command -v sha1sum >/dev/null 2>&1 || missing_deps+=("sha1sum")
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_info "Please install missing tools and run again."
        exit 1
    fi
}

# Run main function
check_dependencies
main "$@"