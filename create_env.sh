#!/bin/bash

# Script to create .env file for local development
echo "Creating .env file for local development..."

cat > .env << EOF
POSTGRES_DB=devdb
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=db
POSTGRES_PORT=5432
DEBUG=True
SECRET_KEY=django-insecure-your-secret-key-here-change-in-production
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0
EOF

echo ".env file created successfully!"
echo "Note: This file is gitignored and should not be committed to version control." 