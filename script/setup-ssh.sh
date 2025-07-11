#!/bin/bash
# SSH Key Setup Script for Superset VM
# This script creates SSH keys and sets up connectivity to your VM

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SSH_KEY_NAME="at-bus-airflow-server"
SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME"
TARGET_USER="mac"
TARGET_HOST="35.244.73.100"
TARGET_PORT="22"

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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists ssh-keygen; then
        print_error "ssh-keygen is not installed. Please install OpenSSH client."
        exit 1
    fi
    
    if ! command_exists ssh-copy-id; then
        print_warning "ssh-copy-id is not available. You'll need to manually copy the public key."
    fi
    
    print_success "Prerequisites check passed"
}

# Function to generate SSH key
generate_ssh_key() {
    print_status "Generating SSH key pair..."
    
    if [ -f "$SSH_KEY_PATH" ]; then
        print_warning "SSH key already exists at $SSH_KEY_PATH"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Using existing SSH key"
            return
        fi
        rm -f "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"
    fi
    
    # Generate SSH key
    ssh-keygen -t rsa -b 4096 -C "ansible@at-bus-airflow" -f "$SSH_KEY_PATH" -N ""
    
    # Set proper permissions
    chmod 600 "$SSH_KEY_PATH"
    chmod 644 "$SSH_KEY_PATH.pub"
    
    print_success "SSH key generated successfully"
}

# Function to copy SSH key to VM
copy_ssh_key() {
    print_status "Copying SSH key to VM..."
    
    if command_exists ssh-copy-id; then
        # Try to copy using ssh-copy-id
        if ssh-copy-id -i "$SSH_KEY_PATH.pub" "$TARGET_USER@$TARGET_HOST"; then
            print_success "SSH key copied successfully using ssh-copy-id"
            return
        else
            print_warning "ssh-copy-id failed. Trying manual method..."
        fi
    fi
    
    # Manual method
    print_status "Using manual method to copy SSH key..."
    print_status "You'll need to manually add the public key to your VM"
    
    echo
    print_status "Public key content:"
    echo "----------------------------------------"
    cat "$SSH_KEY_PATH.pub"
    echo "----------------------------------------"
    echo
    
    print_status "Please add this public key to your VM at:"
    print_status "/home/$TARGET_USER/.ssh/authorized_keys"
    echo
    
    read -p "Press Enter after you've added the key to your VM..."
}

# Function to test SSH connection
test_ssh_connection() {
    print_status "Testing SSH connection..."
    
    if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_HOST" "echo 'SSH connection successful'"; then
        print_success "SSH connection test passed!"
        return 0
    else
        print_error "SSH connection test failed!"
        return 1
    fi
}

# Function to setup SSH config
setup_ssh_config() {
    print_status "Setting up SSH config for easier connection..."
    
    SSH_CONFIG="$HOME/.ssh/config"
    SSH_CONFIG_ENTRY="Host at-bus-superset
    HostName $TARGET_HOST
    User $TARGET_USER
    Port $TARGET_PORT
    IdentityFile $SSH_KEY_PATH
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
"
    
    # Create SSH config directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Check if entry already exists
    if grep -q "Host at-bus-superset" "$SSH_CONFIG" 2>/dev/null; then
        print_warning "SSH config entry already exists"
    else
        # Add entry to SSH config
        echo "$SSH_CONFIG_ENTRY" >> "$SSH_CONFIG"
        chmod 600 "$SSH_CONFIG"
        print_success "SSH config updated"
    fi
}

# Function to display connection information
display_info() {
    print_success "SSH setup completed!"
    echo
    echo "Connection Information:"
    echo "======================"
    echo "Host: $TARGET_HOST"
    echo "User: $TARGET_USER"
    echo "Port: $TARGET_PORT"
    echo "Private Key: $SSH_KEY_PATH"
    echo "Public Key: $SSH_KEY_PATH.pub"
    echo
    echo "Connection Commands:"
    echo "==================="
    echo "Using SSH config: ssh at-bus-superset"
    echo "Direct connection: ssh -i $SSH_KEY_PATH $TARGET_USER@$TARGET_HOST"
    echo
    echo "Ansible Commands:"
    echo "================="
    echo "Test inventory: ansible-inventory --list -i inventory/hosts.yml"
    echo "Ping hosts: ansible all -i inventory/hosts.yml -m ping"
    echo "Deploy: ./scripts/deploy.sh --deploy"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -k, --key-only      Generate SSH key only (don't copy to VM)"
    echo "  -t, --test-only     Test existing SSH connection only"
    echo "  -c, --copy-only     Copy existing SSH key to VM only"
    echo ""
    echo "Examples:"
    echo "  $0                    # Complete setup"
    echo "  $0 --key-only         # Generate key only"
    echo "  $0 --test-only        # Test connection only"
}

# Main script logic
main() {
    case "${1:-}" in
        -h|--help)
            show_usage
            exit 0
            ;;
        -k|--key-only)
            check_prerequisites
            generate_ssh_key
            display_info
            ;;
        -t|--test-only)
            test_ssh_connection
            ;;
        -c|--copy-only)
            copy_ssh_key
            ;;
        "")
            # Complete setup
            check_prerequisites
            generate_ssh_key
            copy_ssh_key
            setup_ssh_config
            if test_ssh_connection; then
                display_info
            else
                print_error "Setup completed but connection test failed"
                print_status "Please check your VM configuration and try again"
                exit 1
            fi
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@" 