#!/bin/bash

# Git Dual Remote Management Script
# Manages both primary and secondary Git remotes for monitoring stack

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Remote names
PRIMARY_REMOTE="origin"
SECONDARY_REMOTE="secondary"

# Function to print colored output
print_status() {
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

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a Git repository!"
        exit 1
    fi
}

# Function to show current status
show_status() {
    print_status "Git Repository Status:"
    echo ""
    
    print_status "Remotes:"
    git remote -v
    echo ""
    
    print_status "Current branch and tracking info:"
    git branch -vv
    echo ""
    
    print_status "Working directory status:"
    git status --short
}

# Function to sync with both remotes
sync_remotes() {
    print_status "Syncing with all remotes..."
    
    # Check if working directory is clean
    if [[ -n $(git status --porcelain) ]]; then
        print_warning "Working directory has uncommitted changes."
        read -p "Do you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Aborted by user."
            exit 0
        fi
    fi
    
    # Fetch from all remotes
    print_status "Fetching from all remotes..."
    git fetch --all
    
    print_success "Sync completed!"
}

# Function to push to both remotes
push_both() {
    local branch=${1:-$(git branch --show-current)}
    
    print_status "Pushing branch '$branch' to both remotes..."
    
    # Check if working directory is clean
    if [[ -n $(git status --porcelain) ]]; then
        print_error "Working directory has uncommitted changes. Please commit first."
        exit 1
    fi
    
    # Push to primary remote
    print_status "Pushing to $PRIMARY_REMOTE..."
    if git push $PRIMARY_REMOTE $branch; then
        print_success "Pushed to $PRIMARY_REMOTE"
    else
        print_error "Failed to push to $PRIMARY_REMOTE"
        exit 1
    fi
    
    # Push to secondary remote
    print_status "Pushing to $SECONDARY_REMOTE..."
    if git push $SECONDARY_REMOTE $branch; then
        print_success "Pushed to $SECONDARY_REMOTE"
    else
        print_error "Failed to push to $SECONDARY_REMOTE"
        exit 1
    fi
    
    print_success "Successfully pushed to both remotes!"
}

# Function to show help
show_help() {
    echo "Git Dual Remote Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  status      - Show current Git status and remotes"
    echo "  sync        - Fetch from all remotes"
    echo "  push [branch] - Push current/specified branch to both remotes"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 status           # Show repository status"
    echo "  $0 sync            # Fetch from all remotes"
    echo "  $0 push            # Push current branch to both remotes"
    echo "  $0 push main       # Push main branch to both remotes"
}

# Main script logic
main() {
    check_git_repo
    
    case "${1:-status}" in
        "status")
            show_status
            ;;
        "sync")
            sync_remotes
            ;;
        "push")
            push_both "$2"
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"