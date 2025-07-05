# GitHub Actions Setup for Airflow Submodule Updates

This workflow automatically updates the `db-at-bus-transform` submodule on your GCP VM Airflow server.

## Required GitHub Secrets

You need to configure the following secrets in your GitHub repository:

1. **GCP_VM_SSH_PRIVATE_KEY**: The private SSH key for accessing your GCP VM
2. **GCP_VM_IP**: The IP address of your GCP VM
3. **GCP_VM_USER**: The username for SSH access to your GCP VM

## Setup Instructions

### 1. Generate SSH Key Pair (if not already done)
```bash
ssh-keygen -t rsa -b 4096 -C "github-actions@your-domain.com"
```

### 2. Add Public Key to GCP VM
Copy the public key content and add it to your GCP VM's `~/.ssh/authorized_keys`:
```bash
# On your GCP VM
echo "YOUR_PUBLIC_KEY_CONTENT" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 3. Configure GitHub Secrets
Go to your GitHub repository → Settings → Secrets and variables → Actions, then add:

- **GCP_VM_SSH_PRIVATE_KEY**: The entire private key content (including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`)
- **GCP_VM_IP**: Your VM's external IP address
- **GCP_VM_USER**: Your VM username (e.g., `ubuntu`, `gcp-user`, etc.)

### 4. Test the Workflow
You can manually trigger the workflow by:
1. Going to Actions tab in your GitHub repository
2. Selecting "Update Airflow Submodule"
3. Clicking "Run workflow"

## Workflow Behavior

- **Triggers**: 
  - On push to main/master branch
  - Manual trigger (workflow_dispatch)
  - Daily at 2 AM UTC (scheduled)
- **Actions**:
  - SSH into your GCP VM
  - Navigate to `airflow-server/dags/db-at-bus-transform`
  - Pull latest changes from the main branch
  - Restart Airflow services (only on push events)

## Troubleshooting

### SSH Connection Issues
- Verify the IP address is correct and accessible
- Check that the SSH key is properly formatted in GitHub secrets
- Ensure the user has proper permissions on the VM

### Permission Issues
- Make sure the user has sudo access for restarting Airflow services
- Verify the user can access the `airflow-server/dags/db-at-bus-transform` directory

### Airflow Service Names
If your Airflow services have different names, update the workflow file:
```yaml
sudo systemctl restart airflow-webserver
sudo systemctl restart airflow-scheduler
```
Replace with your actual service names if different. 