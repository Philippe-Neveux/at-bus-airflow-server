# GitHub Actions Setup Guide

This guide will help you configure the required secrets and variables for the GitHub Actions workflow to deploy Airflow to your GCP VM.

## 🔧 Required Configuration

### 1. GitHub Repository Secrets

Go to your repository → **Settings** → **Secrets and variables** → **Actions** → **Secrets**

Add the following secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `GCP_PROJECT_ID` | Your Google Cloud Project ID | `at-bus-465401` |
| `GCP_SA_KEY` | Base64-encoded service account key JSON | `eyJ0eXBlIjoic2VydmljZV9hY2NvdW50Iiw...` |
| `GCP_VM_NAME` | Name of your GCP VM instance | `airflow-vm` |
| `GCP_ZONE` | GCP zone where VM is located | `australia-southeast1-a` |
| `GCP_REGION` | GCP region | `australia-southeast1` |
| `AIRFLOW_ADMIN_USERNAME` | Airflow admin username | `airflow` |
| `AIRFLOW_ADMIN_PASSWORD` | Airflow admin password | `your-secure-password` |
| `GH_TOKEN` | GitHub token for submodule updates | `ghp_xxxxxxxxxxxxxxxxxxxx` |

### 2. GitHub Repository Variables

Go to your repository → **Settings** → **Secrets and variables** → **Actions** → **Variables**

Add the following variables:

| Variable Name | Description | Example |
|---------------|-------------|---------|
| `GCP_SSH_USER` | SSH username for VM | `gh-actions` |
| `IMAGE_NAME` | Docker image name for Airflow | `airflow_with_deps` |

## 🔑 How to Get These Values

### GCP Service Account Key (`GCP_SA_KEY`)

1. Go to Google Cloud Console → **IAM & Admin** → **Service Accounts**
2. Create a new service account or use existing one
3. Add these roles:
   - `Compute Instance Admin (v1)`
   - `Service Account User`
   - `Storage Admin` (if using GCS)
4. Create a new key (JSON format)
5. Base64 encode the JSON file:
   ```bash
   base64 -i your-service-account-key.json
   ```
6. Copy the base64 output as the secret value

### GCP VM Configuration

1. **VM Name**: The name you gave your VM instance
2. **Zone**: The zone where your VM is located (e.g., `australia-southeast1-a`)
3. **Region**: The region for your zone (e.g., `australia-southeast1`)

### GitHub Token (`GH_TOKEN`)

1. Go to GitHub → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Generate new token with these scopes:
   - `repo` (full control of private repositories)
   - `workflow` (update GitHub Action workflows)
3. Copy the token as the secret value

### SSH User (`GCP_SSH_USER`)

This should be a user that exists on your GCP VM. Common options:
- `gh-actions` (if you created a specific user for GitHub Actions)
- `ubuntu` (default Ubuntu user)
- `debian` (default Debian user)

## 🚀 Testing the Setup

1. **Manual Trigger**: Go to **Actions** → **Deploy Airflow to GCP VM** → **Run workflow**
2. **Push to Main**: Push a commit to the `main` branch
3. **Pull Request**: Create a PR to the `main` branch

## 🔍 Troubleshooting

### SSH Connection Issues

If you see SSH connection errors:

1. **Check VM Status**: Ensure your VM is running
2. **Verify SSH User**: Make sure the `GCP_SSH_USER` exists on the VM
3. **Check Firewall Rules**: Ensure port 22 is open for SSH
4. **Review VM Metadata**: Check if SSH keys are properly added

### Common Error Messages

| Error | Solution |
|-------|----------|
| `Permission denied (publickey)` | Check `GCP_SSH_USER` variable and VM user existence |
| `Connection timeout` | Check VM status and firewall rules |
| `gcloud command not found` | Check GCP authentication setup |
| `Base64 decode error` | Verify `GCP_SA_KEY` is properly base64 encoded |

### Debugging Steps

1. **Check Workflow Logs**: Look for detailed error messages in the Actions tab
2. **Verify Secrets**: Ensure all secrets are properly set (no typos)
3. **Test Locally**: Try running the commands locally with your credentials
4. **Check VM Logs**: Look at the VM's serial console for SSH-related errors

## 📝 Example Configuration

Here's an example of what your secrets and variables should look like:

### Secrets
```
GCP_PROJECT_ID: at-bus-465401
GCP_SA_KEY: eyJ0eXBlIjoic2VydmljZV9hY2NvdW50IiwiaWQiOiIxMjM0NTY3ODkwIiw...
GCP_VM_NAME: airflow-production-vm
GCP_ZONE: australia-southeast1-a
GCP_REGION: australia-southeast1
AIRFLOW_ADMIN_USERNAME: airflow
AIRFLOW_ADMIN_PASSWORD: my-secure-password-123
GH_TOKEN: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Variables
```
GCP_SSH_USER: gh-actions
IMAGE_NAME: airflow_with_deps
```

## 🔒 Security Best Practices

1. **Rotate Secrets Regularly**: Update service account keys and tokens periodically
2. **Use Least Privilege**: Give service accounts only necessary permissions
3. **Monitor Access**: Regularly review who has access to your repository
4. **Secure Passwords**: Use strong, unique passwords for Airflow admin
5. **Restrict VM Access**: Use firewall rules to limit SSH access

## 📞 Getting Help

If you're still having issues:

1. Check the workflow logs for specific error messages
2. Verify all secrets and variables are correctly set
3. Test SSH connection manually to your VM
4. Review GCP VM logs and serial console output 