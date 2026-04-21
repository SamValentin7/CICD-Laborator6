# MyApp Base - CI/CD with Docker & GitHub Actions

A complete web application with MySQL database integration, containerized with Docker, and automated CI/CD pipeline using GitHub Actions.

## Features

- Node.js/Express backend with REST API
- MySQL database with connection pooling
- Docker containerization
- Docker Compose orchestration
- GitHub Actions CI/CD pipeline
- Simple web interface for managing items

## Project Structure

```
myapp-base/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # GitHub Actions CI/CD pipeline
├── public/
│   └── index.html             # Frontend web interface
├── init.sql                   # Database initialization script
├── server.js                  # Express application
├── package.json               # Node.js dependencies
├── Dockerfile                 # Docker image definition
├── docker-compose.yml         # Service orchestration
├── .env.example               # Environment variables template
└── README.md                  # This file
```

## Prerequisites

- Docker and Docker Compose installed
- Node.js 18+ (for local development)
- Git

## Quick Start with Docker Compose

### 1. Clone the repository

```bash
git clone <your-repo-url>
cd myapp-base
```

### 2. Configure environment variables

```bash
cp .env.example .env
# Edit .env file with your settings if needed
```

### 3. Start the application

```bash
docker-compose up -d
```

This will start:
- MySQL database on port 3306
- Node.js application on port 3000

### 4. Access the application

Open your browser and navigate to: http://localhost:3000

### 5. View logs

```bash
docker-compose logs -f
```

### 6. Stop the application

```bash
docker-compose down
```

To also remove the data volume:

```bash
docker-compose down -v
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/items` | Get all items |
| POST | `/api/items` | Create new item |
| DELETE | `/api/items/:id` | Delete item |
| GET | `/health` | Health check endpoint |

## Database Schema

The application uses a single table `items`:

```sql
CREATE TABLE items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Local Development

### Install dependencies

```bash
npm install
```

### Set up local MySQL

1. Install MySQL on your system
2. Create database: `myapp_base`
3. Update `.env` file with your MySQL credentials

### Run the application

```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

The application will be available at http://localhost:3000

## Docker Commands

### Build the image manually

```bash
docker build -t myapp-base .
```

### Run the container manually

```bash
docker run -p 3000:3000 --env-file .env myapp-base
```

### View running containers

```bash
docker ps
```

### View logs

```bash
docker logs myapp-web
docker logs myapp-mysql
```

## GitHub Actions CI/CD Pipeline

The pipeline consists of three jobs:

### 1. Test Job
- Runs on every push and pull request
- Sets up MySQL service
- Installs dependencies
- Runs tests (currently placeholder)

### 2. Build Job
- Runs after successful tests on push events
- Builds Docker image
- Pushes to GitHub Container Registry (GHCR)
- Tags: branch name, SHA, and latest (for main branch)

### 3. Deploy Job
- Runs after build on main branch pushes
- Placeholder for deployment steps
- Configure with your deployment target (SSH, Kubernetes, etc.)

### Setting up GitHub Actions

1. Push code to GitHub repository
2. GitHub Actions will automatically run on pushes to main/master
3. The Docker image will be published to GHCR

### Customizing Deployment

Edit the `deploy` job in `.github/workflows/ci-cd.yml`:

```yaml
- name: Deploy to production
  run: |
    echo "Deploying to production..."
    # Example for SSH deployment:
    # ssh user@your-server "docker pull ghcr.io/username/myapp-base:latest && cd /path/to/app && docker-compose up -d"
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_HOST` | localhost | MySQL host |
| `DB_PORT` | 3306 | MySQL port |
| `DB_USER` | root | MySQL username |
| `DB_PASSWORD` | password | MySQL password |
| `DB_NAME` | myapp_base | Database name |
| `NODE_ENV` | development | Node environment |
| `PORT` | 3000 | Application port |

## Troubleshooting

### Database connection errors

1. Check if MySQL container is running:
   ```bash
   docker-compose ps
   ```

2. View MySQL logs:
   ```bash
   docker-compose logs mysql
   ```

3. Ensure environment variables are set correctly

### Port already in use

Change ports in `docker-compose.yml`:
```yaml
ports:
  - "3001:3000"  # Host:Container
```

### Permission errors on Linux

Add your user to docker group:
```bash
sudo usermod -aG docker $USER
```

## Docker Hub Authentication Setup

To push Docker images to Docker Hub from GitHub Actions, you need to configure the following secrets in your repository:

### Required Secrets

1. **DOCKERHUB_USERNAME** - Your Docker Hub username
2. **DOCKERHUB_TOKEN** - Your Docker Hub access token (not your password)

### Setting Up Docker Hub Access Token

1. Log in to [Docker Hub](https://hub.docker.com)
2. Click on your profile picture → **Account Settings**
3. Go to **Security** → **New Access Token**
4. Create a token with **Read & Write** permissions
5. Copy the token (it will only be shown once)

### Adding Secrets to GitHub Repository

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

| Secret Name | Value |
|--------------|-------|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Your Docker Hub access token |

### Optional Server Deployment Secrets

If you want to enable automatic deployment to a server via SSH, add these additional secrets:

| Secret Name | Description |
|--------------|-------------|
| `SERVER_HOST` | Your server's IP address or domain |
| `SERVER_USER` | SSH username (e.g., ubuntu, root) |
| `SSH_PRIVATE_KEY` | Private SSH key for authentication |

### Creating SSH Key for Deployment

```bash
# Generate SSH key pair (if you don't have one)
ssh-keygen -t rsa -b 4096 -C "deploy-key" -f deploy_key -N ""

# The private key (deploy_key) goes to GitHub secrets as SSH_PRIVATE_KEY
# The public key (deploy_key.pub) goes to server's ~/.ssh/authorized_keys
```

## Security Notes

- Change default MySQL password in production
- Use secrets management for sensitive data
- Configure firewall rules
- Enable SSL/TLS for database connections
- Use non-root users in containers
- Never commit `.env` files with real credentials
- Rotate Docker Hub access tokens regularly

## License

MIT
