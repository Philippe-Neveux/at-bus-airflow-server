#!/bin/bash

# GCP SSH Setup Script for GitHub Actions
set -e

echo "🔧 Setting up GCP SSH access for GitHub Actions..."

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed. Please install it first:"
    echo "   https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ Not authenticated with gcloud. Please run:"
    echo "   gcloud auth login"
    exit 1
fi

# Get project ID
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No project set. Please set your project:"
    echo "   gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "📋 Current project: $PROJECT_ID"

# Get VM details
read -p "Enter VM instance name: " VM_NAME
read -p "Enter VM zone (e.g., us-central1-a): " ZONE
read -p "Enter SSH username: " SSH_USER

# Generate SSH key
echo "🔑 Generating SSH key..."
ssh-keygen -t ed25519 -f ~/.ssh/at-bus-airflow-server-key -N "" -C "$SSH_USER@$PROJECT_ID"

# Add SSH key to VM
echo "🔧 Adding SSH key to VM..."
gcloud compute instances add-metadata $VM_NAME \
    --zone=$ZONE \
    --metadata ssh-keys="$SSH_USER:$(cat ~/.ssh/at-bus-airflow-server-key.pub)"

# Create service account
echo "👤 Creating service account..."
gcloud iam service-accounts create gh-at-bus-airflow-server \
    --description="Service account for GitHub Actions" \
    --display-name="GitHub Actions" \
    --project=$PROJECT_ID

# Grant necessary roles
echo "🔐 Granting permissions..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:gh-at-bus-airflow-server@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.instanceAdmin.v1"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:gh-at-bus-airflow-server@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

# Create and download service account key
echo "📄 Creating service account key..."
gcloud iam service-accounts keys create ~/.ssh/gcp-sa-key.json \
    --iam-account=gh-at-bus-airflow-server@$PROJECT_ID.iam.gserviceaccount.com

# Base64 encode the key
SA_KEY_B64=$(base64 -i ~/.ssh/gcp-sa-key.json)

# Get VM IP
VM_IP=$(gcloud compute instances describe $VM_NAME \
    --zone=$ZONE \
    --format="value(networkInterfaces[0].accessConfigs[0].natIP)")

echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "📋 GitHub Secrets to add:"
echo "GCP_PROJECT_ID=$PROJECT_ID"
echo "GCP_SA_KEY=$SA_KEY_B64"
echo "GCP_VM_NAME=$VM_NAME"
echo "GCP_ZONE=$ZONE"
echo "GCP_REGION=$(echo $ZONE | cut -d'-' -f1,2)"
echo "GCP_SSH_USER=$SSH_USER"
echo "GCP_SSH_PUBLIC_KEY=$(cat ~/.ssh/at-bus-airflow-server-key.pub)"
echo ""
echo "🔑 SSH Private Key (for manual access):"
echo "$(cat ~/.ssh/at-bus-airflow-server-key)"
echo ""
echo "🌐 VM IP Address: $VM_IP"
echo ""
echo "🧪 Test SSH connection:"
echo "ssh -i ~/.ssh/at-bus-airflow-server-key $SSH_USER@$VM_IP"
echo ""
echo "⚠️  Security notes:"
echo "- Keep the private key secure"
echo "- The service account key is base64 encoded"
echo "- Add all secrets to GitHub repository settings"
echo "- Consider using GitHub Environments for different stages"