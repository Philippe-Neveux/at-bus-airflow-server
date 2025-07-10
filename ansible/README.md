# Ansible Infrastructure Management

This directory contains Ansible playbooks and roles for managing the AT Bus infrastructure.

## 📁 Project Structure

```
at-bus-airflow-server/
├── airflow/                    # Airflow application files
│   ├── dags/                  # Airflow DAGs
│   ├── plugins/               # Airflow plugins
│   ├── config/                # Airflow configuration
│   ├── logs/                  # Airflow logs
│   └── docker-compose.yaml    # Local development compose file
├── ansible/                   # Ansible automation
│   ├── inventory/             # Inventory files
│   │   ├── production.yml     # Production servers
│   │   └── group_vars/        # Group-specific variables
│   │       ├── all.yml        # Global variables
│   │       └── airflow_servers.yml
│   ├── playbooks/             # Playbook organization
│   │   ├── deploy/            # Deployment playbooks
│   │   │   └── airflow.yml    # Deploy Airflow
│   │   ├── operations/        # Operational playbooks
│   │   │   ├── stop-airflow.yml
│   │   │   ├── restart-airflow.yml
│   │   │   └── status-airflow.yml
│   │   └── maintenance/       # Maintenance playbooks
│   ├── roles/                 # Reusable roles
│   │   ├── common/            # Common server setup
│   │   ├── airflow/           # Airflow installation
│   │   ├── docker/            # Docker installation
│   │   ├── nginx/             # Nginx configuration
│   │   └── monitoring/        # Monitoring setup
│   ├── vars/                  # Global variables
│   │   └── main.yml
│   ├── files/                 # Static files
│   │   ├── certificates/
│   │   ├── configs/
│   │   └── scripts/
│   ├── templates/             # Global templates
│   │   └── global-templates/
│   ├── Makefile               # Convenience commands
│   ├── run-playbook.sh        # Helper script
│   └── README.md              # This file
└── .github/workflows/         # CI/CD workflows
    └── deploy-airflow.yml
```

## 🚀 Usage

### Using Makefile (Recommended)
```bash
cd ansible

# Deploy Airflow
make deploy-airflow

# Deploy with verbose output
make deploy-airflow-v

# Stop Airflow
make stop-airflow

# Restart Airflow
make restart-airflow

# Check status
make check-airflow-status

# Check syntax of all playbooks
make check-syntax-playbooks
```

### Using Helper Script
```bash
cd ansible

# Deploy Airflow
./run-playbook.sh deploy/airflow

# Stop Airflow
./run-playbook.sh operations/stop-airflow

# Check status
./run-playbook.sh operations/status-airflow

# With verbose output
./run-playbook.sh operations/status-airflow -v
```

### Using Direct Commands
```bash
cd ansible

# Deploy Airflow
uv run ansible-playbook -i inventory/production.yml playbooks/deploy/airflow.yml

# Operations
uv run ansible-playbook -i inventory/production.yml playbooks/operations/stop-airflow.yml
```

## 🔧 Configuration

### Variables
- **Global variables**: `vars/main.yml`
- **Group variables**: `inventory/group_vars/airflow_servers.yml`
- **Host variables**: `inventory/production.yml`

### File Organization
- **Airflow DAGs**: `../airflow/dags/` → deployed to `/opt/airflow/dags/`
- **Airflow Plugins**: `../airflow/plugins/` → deployed to `/opt/airflow/plugins/`
- **Airflow Config**: `../airflow/config/` → deployed to `/opt/airflow/config/`

### SSH Configuration
Make sure your SSH key is available at `~/.ssh/github-actions-key`

## 📋 Available Playbooks

### Deployment
- `playbooks/deploy/airflow.yml` - Full Airflow deployment

### Operations
- `playbooks/operations/stop-airflow.yml` - Stop Airflow services
- `playbooks/operations/restart-airflow.yml` - Restart Airflow services
- `playbooks/operations/status-airflow.yml` - Check Airflow status

### Maintenance
- (Future) System updates, security patches, etc.

## 🔄 CI/CD

The GitHub Actions workflow automatically:
1. Updates the inventory with the current VM IP
2. Copies Airflow files from `airflow/` directory
3. Deploys using the Ansible playbooks
4. Verifies the deployment

## 📝 Development

### Local Development
- Use `airflow/docker-compose.yaml` for local development
- DAGs in `airflow/dags/` are automatically deployed to production
- Configuration in `airflow/config/` is deployed to production

### Adding New DAGs
1. Add your DAG file to `airflow/dags/`
2. Commit and push to trigger deployment
3. The DAG will be automatically deployed to production

# Airflow Ansible Deployment

This Ansible playbook automates the deployment of Apache Airflow to a GCP VM using Docker Compose.

## Prerequisites

- Ansible 2.9+ installed on your local machine
- SSH access to the target GCP VM
- GCP service account key file for Airflow
- Docker image built and pushed to Google Container Registry

## Configuration

### 1. Update Inventory

Edit `inventory.yml` and update the following variables:

```yaml
ansible_host: YOUR_GCP_VM_IP
ansible_user: YOUR_SSH_USER
ansible_ssh_private_key_file: ~/.ssh/your_gcp_key
gcp_project_id: YOUR_GCP_PROJECT_ID
gcp_region: YOUR_GCP_REGION
```

### 2. Prepare Credentials

Place your GCP service account key file in the `credentials/` directory:

```bash
mkdir -p credentials/
# Copy your service account key to files/credentials/airflow-server-key.json
```

### 3. Install Ansible Collections

```bash
ansible-galaxy collection install -r requirements.yml
```

## Deployment

### Full Deployment

```bash
ansible-playbook playbook.yml
```

#### Override for Specific Deployments
```bash
# Force clean deployment
ansible-playbook -i inventory/production.yml playbooks/deploy/airflow.yml -e "clean_deployment=true"

# Use synchronize method
ansible-playbook -i inventory/production.yml playbooks/deploy/airflow.yml -e "use_synchronize=true"
```

### Deploy Specific Components

```bash
# Deploy only Docker
ansible-playbook playbook.yml --tags docker

# Deploy only Airflow
ansible-playbook playbook.yml --tags airflow

# Deploy only Nginx
ansible-playbook playbook.yml --tags nginx
```

## Verification

After deployment, verify the installation:

1. **Check Airflow Web UI**: http://YOUR_VM_IP:8080
2. **Check Nginx Proxy**: http://YOUR_VM_IP (port 80)
3. **Check Flower**: http://YOUR_VM_IP:5555 (if enabled)

### Manual Verification Commands

```bash
# SSH to the server
ssh -i ~/.ssh/your_gcp_key user@YOUR_VM_IP

# Check Airflow containers
cd /opt/airflow
docker-compose ps

# Check Airflow logs
docker-compose logs airflow-webserver
docker-compose logs airflow-scheduler

# Check systemd services
sudo systemctl status airflow
sudo systemctl status nginx
```

## Services

The deployment includes the following services:

- **Airflow Webserver**: Port 8080
- **Airflow Scheduler**: Background service
- **Airflow Worker**: Celery worker for task execution
- **Airflow Triggerer**: For deferred operators
- **PostgreSQL**: Airflow metadata database
- **Redis**: Celery broker
- **Nginx**: Reverse proxy (port 80)
- **Flower**: Celery monitoring (port 5555, optional)

## Monitoring

The deployment includes basic monitoring:

- **Log Rotation**: Daily rotation of Airflow logs
- **Health Checks**: Container health monitoring
- **Resource Monitoring**: Disk and memory usage checks
- **Auto-restart**: Automatic restart of failed containers

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure the airflow user has proper permissions
   ```bash
   sudo chown -R airflow:airflow /opt/airflow
   ```

2. **Container Startup Issues**: Check Docker logs
   ```bash
   docker-compose logs
   ```

3. **Database Connection Issues**: Verify PostgreSQL is running
   ```bash
   docker-compose ps postgres
   ```

### Log Locations

- **Airflow Logs**: `/opt/airflow/logs/`
- **Docker Logs**: `docker-compose logs [service-name]`
- **System Logs**: `/var/log/syslog`
- **Nginx Logs**: `/var/log/nginx/`

## Maintenance

### Update Airflow

1. Update the image in your Container Registry
2. Update the `IMAGE_NAME` variable in inventory
3. Run the playbook again

### Backup

```bash
# Backup Airflow database
docker-compose exec postgres pg_dump -U airflow airflow > backup.sql

# Backup DAGs and configuration
tar -czf airflow-backup.tar.gz /opt/airflow/dags /opt/airflow/config
```

### Scaling

To scale workers:

```bash
cd /opt/airflow
docker-compose up -d --scale airflow-worker=3
```

## Security Considerations

- Change default passwords in production
- Use HTTPS with proper SSL certificates
- Restrict network access with firewall rules
- Regularly update Docker images and system packages
- Use secrets management for sensitive data

## Support

For issues and questions:
1. Check the logs mentioned above
2. Review Airflow documentation
3. Check Ansible playbook syntax: `ansible-playbook --syntax-check playbook.yml` 