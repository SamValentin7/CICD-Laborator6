# Docker Hub Authentication Setup Guide

This guide explains how to configure Docker Hub authentication for GitHub Actions to automatically build and push Docker images.

## Prerequisites

- A Docker Hub account (https://hub.docker.com)
- A GitHub repository with the code
- Admin access to the GitHub repository (to add secrets)

## Step 1: Create Docker Hub Access Token

1. Log in to [Docker Hub](https://hub.docker.com)
2. Click on your profile picture in the top right corner
3. Select **Account Settings**
4. Navigate to the **Security** tab
5. Click **New Access Token**
6. Configure the token:
   - **Description**: `github-actions-deploy` (or any descriptive name)
   - **Access**: Select **Read & Write** (required for pushing images)
7. Click **Create**
8. **IMPORTANT**: Copy the token immediately - it will only be shown once and cannot be retrieved later!

## Step 2: Add Secrets to GitHub Repository

1. Navigate to your GitHub repository
2. Click **Settings** (gear icon in the top right)
3. In the left sidebar, expand **Secrets and variables** and click **Actions**
4. Click **New repository secret**

### Add Docker Hub Username Secret

- **Name**: `DOCKERHUB_USERNAME`
- **Value**: Your Docker Hub username (not your email)
- Click **Add secret**

### Add Docker Hub Token Secret

- **Name**: `DOCKERHUB_TOKEN`
- **Value**: The access token you copied from Docker Hub
- Click **Add secret**

## Step 3: Verify Configuration

1. Go to the **Actions** tab in your GitHub repository
2. You should see the workflow files listed
3. Push a commit to the main/master branch to trigger the workflow
4. In the workflow run, the "Log in to Docker Hub" step should show:
   ```
   Login Succeeded
   ```

## Step 4: Optional - Server Deployment Secrets

If you want the workflow to automatically deploy to a server via SSH, add these additional secrets:

### Generate SSH Key Pair

```bash
# Generate a new SSH key pair (skip if you already have one)
ssh-keygen -t rsa -b 4096 -C "deploy-key" -f deploy_key -N ""

# This creates:
# - deploy_key (private key) → add to GitHub as SSH_PRIVATE_KEY
# - deploy_key.pub (public key) → add to server's ~/.ssh/authorized_keys
```

### Add SSH Secrets to GitHub

1. **SSH_PRIVATE_KEY**:
   - Open `deploy_key` file in a text editor
   - Copy the entire contents (including `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`)
   - Add as secret named `SSH_PRIVATE_KEY`

2. **SERVER_HOST**:
   - Your server's IP address or domain name
   - Example: `123.45.67.89` or `myserver.example.com`

3. **SERVER_USER**:
   - SSH username for the server
   - Example: `ubuntu`, `root`, or `deploy`

### Add Public Key to Server

On your server, add the public key to authorized keys:

```bash
# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# Add public key to authorized_keys
cat /path/to/deploy_key.pub >> ~/.ssh/authorized_keys

# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## Troubleshooting

### "Login failed" in workflow

- Verify the token is correct (you may need to create a new one)
- Ensure the token has **Read & Write** permissions
- Check that `DOCKERHUB_USERNAME` matches your Docker Hub username exactly

### "Permission denied" when pushing

- Ensure you're using an access token, not your Docker Hub password
- Docker Hub deprecated password authentication for Docker CLI and APIs

### Secrets not showing up in workflow

- Secrets are only available to workflows in the same repository
- Make sure the workflow file is in `.github/workflows/`
- Secrets are case-sensitive - use exact names from the workflow file

## Security Best Practices

1. **Never commit secrets** to the repository
2. **Rotate tokens regularly** (every 90 days recommended)
3. **Use minimal permissions** - only grant Read & Write, not Admin
4. **Revoke unused tokens** from Docker Hub security settings
5. **Use separate tokens** for different projects/environments
6. **Monitor Docker Hub activity** for unauthorized access

## Workflow Files Using These Secrets

- [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml) - Uses `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` for building and pushing images

## Additional Resources

- [Docker Hub Documentation: Access Tokens](https://docs.docker.com/docker-hub/access-tokens/)
- [GitHub Actions Documentation: Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Actions: Authenticating with Docker Hub](https://docs.github.com/en/actions/publishing-packages/publishing-docker-images)
