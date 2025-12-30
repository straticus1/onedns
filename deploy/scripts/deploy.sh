#!/bin/bash
# adsdnsgo - Full Deployment Script
# Deploys to OCI using Terraform and Ansible

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_DIR="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$DEPLOY_DIR/terraform"
ANSIBLE_DIR="$DEPLOY_DIR/ansible"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[adsdnsgo]${NC} $1"; }
warn() { echo -e "${YELLOW}[warning]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; exit 1; }

usage() {
    cat << EOF
Usage: $0 <command> [options]

Commands:
    init        Initialize Terraform
    plan        Show Terraform plan
    apply       Apply Terraform and run Ansible
    destroy     Destroy infrastructure
    ansible     Run Ansible deployment only
    status      Show deployment status
    api-key     Generate and display API key

Options:
    -y          Auto-approve (skip confirmation)
    -h          Show this help

Examples:
    $0 init
    $0 plan
    $0 apply -y
    $0 ansible
EOF
}

check_deps() {
    log "Checking dependencies..."
    command -v terraform >/dev/null 2>&1 || error "terraform not found"
    command -v ansible-playbook >/dev/null 2>&1 || error "ansible not found"
    command -v jq >/dev/null 2>&1 || error "jq not found"

    if [ ! -f "$TERRAFORM_DIR/terraform.tfvars" ]; then
        warn "terraform.tfvars not found"
        warn "Copy terraform.tfvars.example and fill in your OCI credentials"
        error "Missing configuration"
    fi
}

terraform_init() {
    log "Initializing Terraform..."
    cd "$TERRAFORM_DIR"
    terraform init
}

terraform_plan() {
    log "Planning infrastructure..."
    cd "$TERRAFORM_DIR"
    terraform plan -out=tfplan
}

terraform_apply() {
    local auto_approve="$1"
    log "Applying Terraform..."
    cd "$TERRAFORM_DIR"

    if [ "$auto_approve" == "-y" ]; then
        terraform apply -auto-approve tfplan
    else
        terraform apply tfplan
    fi

    log "Terraform apply complete"
}

run_ansible() {
    log "Running Ansible deployment..."
    cd "$ANSIBLE_DIR"

    # Wait for instance to be ready
    log "Waiting for instance to be reachable..."
    sleep 30

    ansible-playbook playbooks/deploy.yml -i inventory/oci-hosts.yml
}

show_status() {
    log "Deployment Status:"
    cd "$TERRAFORM_DIR"

    if terraform state list >/dev/null 2>&1; then
        echo ""
        terraform output -json | jq -r '
            "Instance IP: \(.instance_public_ip.value)",
            "API Endpoint: \(.api_endpoint.value)",
            "SSH Command: \(.ssh_command.value)",
            "API Key ID: \(.api_key_id.value)"
        '
        echo ""

        IP=$(terraform output -raw instance_public_ip)
        log "Testing health endpoint..."
        if curl -s "http://$IP:5000/health" | jq . 2>/dev/null; then
            log "API is healthy!"
        else
            warn "API not responding yet"
        fi
    else
        warn "No infrastructure deployed"
    fi
}

show_api_key() {
    cd "$TERRAFORM_DIR"
    if terraform state list >/dev/null 2>&1; then
        log "API Credentials:"
        echo ""
        cat "$DEPLOY_DIR/api-key.json" | jq .
        echo ""
        log "API Key (sensitive):"
        terraform output -raw api_key
        echo ""
    else
        error "No infrastructure deployed"
    fi
}

destroy() {
    local auto_approve="$1"
    warn "This will destroy all adsdnsgo infrastructure!"
    cd "$TERRAFORM_DIR"

    if [ "$auto_approve" == "-y" ]; then
        terraform destroy -auto-approve
    else
        terraform destroy
    fi
}

# Main
case "${1:-}" in
    init)
        check_deps
        terraform_init
        ;;
    plan)
        check_deps
        terraform_plan
        ;;
    apply)
        check_deps
        terraform_plan
        terraform_apply "$2"
        run_ansible
        show_status
        ;;
    ansible)
        run_ansible
        ;;
    status)
        show_status
        ;;
    api-key)
        show_api_key
        ;;
    destroy)
        destroy "$2"
        ;;
    -h|--help|help)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac
