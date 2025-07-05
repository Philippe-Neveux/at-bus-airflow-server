# Docker Pull Playbooks

This directory contains playbooks for pulling Docker images on target servers.

## Available Playbooks

### docker-pull.yml (Command Line)
Simple playbook that accepts variables via command line for automation.

**Usage:**
```bash
# Basic usage
cd ansible
ansible-playbook -i inventory/production.yml playbooks/operations/docker-pull.yml -e "docker_image_name=nginx:latest"
```

**Features:**
- Command line variable input
- Suitable for automation/CI/CD
- Validates input and displays detailed results
- Uses Docker role for image pulling

## Variables

- `docker_image_name` (required): The Docker image to pull (e.g., `nginx:latest`, `postgres:13`)

## Makefile Integration

The playbook is integrated with the Makefile for easy usage:

```bash
# Pull with custom image
make docker-pull-custom IMAGE=nginx:latest

# Pull from Google Cloud Artifact Registry
make docker-pull-custom IMAGE=australia-southeast1-docker.pkg.dev/glossy-apex-462002-i3/airflow-images/airflow_with_dep:latest
```

## Authentication

**Note:** The playbook currently has authentication tasks commented out. For pulling images from private registries (like Google Cloud Artifact Registry), you may need to:

1. Ensure Docker authentication is already configured on the target servers
2. Uncomment the authentication tasks in the playbook if needed
3. Verify that the target servers have the necessary credentials and permissions

## Requirements

- Docker must be installed on target servers
- Target servers must have internet access to pull images
- Ansible user must have sudo privileges
- For private registries: appropriate authentication must be configured 