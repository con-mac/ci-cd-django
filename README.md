# CI/CD Django Project

A Django project with comprehensive CI/CD pipeline using Jenkins, Docker Compose, and DevSecOps tools.

## Project Structure

```
ci-cd-django/
├── app/                    # Django application code
│   ├── manage.py
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── core/              # Django settings
│   └── apps/              # Django apps
├── jenkins/               # Jenkins configuration
│   ├── Dockerfile
│   ├── casc.yaml
│   └── plugins.txt
├── docker-compose.yml     # Base compose file
├── docker-compose.local.yml    # Local development overrides
├── docker-compose.jenkins.yml  # Jenkins CI/CD overrides
├── Jenkinsfile           # Jenkins pipeline
├── Makefile              # Development commands
├── create_env.sh         # Script to create .env file for local development
└── .env                  # Environment variables (optional, created by script)
```

## Quick Start

### Local Development

```bash
# Create .env file (optional, for local development)
./create_env.sh

# Start the application
make up

# Run migrations
make migrate

# View logs
make logs

# Stop the application
make down
```

### CI/CD Pipeline

The project uses Jenkins for CI/CD with the following stages:
- Build Docker images
- Run database migrations
- Start services
- Health checks
- Security scans (Trivy, OWASP Dependency-Check, DAST)

## Docker Compose Files

### `docker-compose.yml` (Base)
Contains the core service definitions for web and database with inline environment variables.

### `docker-compose.local.yml` (Local Development)
- Uses relative paths for volume mounts
- Optimized for local development
- Use with: `docker-compose -f docker-compose.yml -f docker-compose.local.yml`

### `docker-compose.jenkins.yml` (CI/CD)
- Uses absolute host paths for volume mounts
- Configured for Jenkins environment
- Use with: `docker-compose -f docker-compose.yml -f docker-compose.jenkins.yml`

## Available Commands

### Development Commands
- `make up` - Start services
- `make down` - Stop services
- `make build` - Build images
- `make migrate` - Run migrations
- `make logs` - View logs
- `make shell` - Open shell in web container

### CI/CD Commands
- `make ci-up` - Start CI services
- `make ci-down` - Stop CI services
- `make ci-build` - Build CI images
- `make ci-migrate` - Run CI migrations

## Environment Variables

Environment variables are now defined inline in the docker-compose files to avoid dependency on external `.env` files. The following variables are configured:

```
POSTGRES_DB=devdb
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=db
POSTGRES_PORT=5432
DEBUG=True
SECRET_KEY=django-insecure-your-secret-key-here-change-in-production
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0
```

For local development, you can optionally create a `.env` file using the provided script:
```bash
./create_env.sh
```

## Troubleshooting

### Volume Mount Issues
If you encounter volume mount issues in Jenkins:
1. Ensure the host path exists: `/home/con-mac/dev/projects/ci-cd-django`
2. Check that the Jenkins container has access to the host Docker socket
3. Verify the project is mounted correctly in the Jenkins container

### Database Connection Issues
1. Ensure the database container is running: `make ps`
2. Check database logs: `make logs-db`
3. Verify environment variables are properly set in docker-compose files

### Jenkins Pipeline Issues
1. The pipeline no longer depends on external `.env` files
2. Environment variables are defined inline in docker-compose files
3. Check that all required files are present in the Jenkins workspace
