#!/bin/bash

# Jenkins Pipeline Setup Script
# This script helps set up the required Jenkins configuration

set -e

echo "🔧 Jenkins Pipeline Setup Script"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

print_status "Checking prerequisites..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
else
    print_status "Docker is installed: $(docker --version)"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
else
    print_status "Docker Compose is installed: $(docker-compose --version)"
fi

# Check if curl is available
if ! command -v curl &> /dev/null; then
    print_error "curl is not installed. Please install curl first."
    exit 1
else
    print_status "curl is installed"
fi

print_status "Prerequisites check completed successfully!"

echo ""
print_status "Next steps to complete setup:"
echo ""
echo "1. 📋 Install required Jenkins plugins:"
echo "   - SonarQube Scanner"
echo "   - Email Extension Plugin"
echo "   - Credentials Plugin"
echo "   - Pipeline"
echo "   - Git"
echo "   - Docker Pipeline"
echo ""
echo "2. 🔐 Create Jenkins credentials:"
echo "   - SONARQUBE_TOKEN (Secret text)"
echo "   - DT_API_KEY (Secret text, optional)"
echo "   - WEBHOOK_URL (Secret text, optional)"
echo ""
echo "3. ⚙️  Configure SonarQube server:"
echo "   - Name: My SonarQube Server"
echo "   - URL: http://9.9.8.100196:9000"
echo ""
echo "4. 📧 Configure email notifications:"
echo "   - Set up SMTP settings"
echo "   - Test email configuration"
echo ""
echo "5. 🧪 Test the configuration:"
echo "   - Run the pipeline manually"
echo "   - Check all stages execute successfully"
echo ""

# Test SonarQube connectivity if token is provided
if [[ -n "$SONARQUBE_TOKEN" ]]; then
    print_status "Testing SonarQube connectivity..."
    if curl -s -u "$SONARQUBE_TOKEN:" "http://9.9.8.100196:9000/api/system/status" > /dev/null; then
        print_status "SonarQube connection successful!"
    else
        print_warning "SonarQube connection failed. Please check your token and server URL."
    fi
else
    print_warning "SONARQUBE_TOKEN not set. Set it to test SonarQube connectivity:"
    echo "export SONARQUBE_TOKEN='your-token-here'"
fi

echo ""
print_status "Setup script completed!"
print_status "Please follow the manual steps above to complete the configuration."
print_status "Refer to jenkins-setup-guide.md for detailed instructions." 