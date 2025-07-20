# Jenkins Pipeline Setup Guide

This guide will help you configure Jenkins to work with the improved CI/CD pipeline.

## Prerequisites

- Jenkins server running with admin access
- SonarQube server accessible at `http://9.9.8.100196:9000`
- Docker and Docker Compose installed on Jenkins agent

## 1. Install Required Jenkins Plugins

Navigate to **Manage Jenkins** → **Manage Plugins** → **Available** and install:

### Essential Plugins
- **SonarQube Scanner** - For code quality analysis
- **Email Extension Plugin** - For email notifications
- **Credentials Plugin** - For secure credential management
- **Pipeline** - For declarative pipelines
- **Git** - For Git integration
- **Docker Pipeline** - For Docker operations

### Optional Plugins
- **OWASP Dependency-Check** - For dependency scanning
- **OWASP ZAP** - For DAST scanning
- **Trivy** - For container scanning

## 2. Configure SonarQube Server

1. Go to **Manage Jenkins** → **Configure System**
2. Find **SonarQube servers** section
3. Add a new SonarQube server:
   - **Name**: `My SonarQube Server`
   - **Server URL**: `http://9.9.8.100196:9000`
   - **Server authentication token**: Create a credential (see step 3)

## 3. Create Jenkins Credentials

Navigate to **Manage Jenkins** → **Manage Credentials** → **System** → **Global credentials** → **Add Credentials**

### Required Credentials

#### 1. SonarQube Token
- **Kind**: Secret text
- **ID**: `SONARQUBE_TOKEN`
- **Secret**: Your SonarQube user token
- **Description**: `SonarQube authentication token`

#### 2. Dependency-Track API Key (Optional)
- **Kind**: Secret text
- **ID**: `DT_API_KEY`
- **Secret**: Your Dependency-Track API key
- **Description**: `Dependency-Track API key for SBOM upload`

#### 3. Webhook URL (Optional)
- **Kind**: Secret text
- **ID**: `WEBHOOK_URL`
- **Secret**: Your webhook endpoint URL
- **Description**: `Webhook URL for notifications`

## 4. Configure Email Notifications

1. Go to **Manage Jenkins** → **Configure System**
2. Find **Extended E-mail Notification** section
3. Configure SMTP settings:
   - **SMTP server**: Your SMTP server
   - **SMTP Port**: 587 (or your port)
   - **Use SSL**: Yes (recommended)
   - **User Name**: Your email username
   - **Password**: Your email password
   - **Reply-To List**: Your email address

## 5. SonarQube Token Generation

To generate a SonarQube user token:

1. Log into your SonarQube instance
2. Go to **User** → **My Account** → **Security**
3. Generate a new token
4. Copy the token and add it to Jenkins credentials as `SONARQUBE_TOKEN`

## 6. Test Configuration

### Test SonarQube Connection
```bash
# From Jenkins agent
curl -u YOUR_TOKEN: http://9.9.8.100196:9000/api/system/status
```

### Test Email Configuration
1. Go to **Manage Jenkins** → **Configure System**
2. Find **Extended E-mail Notification**
3. Click **Test configuration by sending test e-mail**

## 7. Pipeline Configuration

### Job Configuration
1. Create a new **Pipeline** job
2. Configure **Pipeline script from SCM**
3. Set **Repository URL**: `https://github.com/con-mac/ci-cd-django.git`
4. Set **Script Path**: `Jenkinsfile`

### Environment Variables (Optional)
You can set these in the job configuration if needed:
- `SONAR_HOST_URL`: SonarQube server URL
- `SONAR_PROJECT_KEY`: Project key in SonarQube
- `SONAR_PROJECT_NAME`: Project name in SonarQube

## 8. Troubleshooting

### Common Issues

#### SonarQube Authentication Failed
- Verify the token is correct
- Check SonarQube server is accessible
- Ensure the token has proper permissions

#### Email Notifications Not Working
- Check SMTP configuration
- Verify email credentials
- Test email configuration

#### Docker Commands Failing
- Ensure Docker is installed on Jenkins agent
- Check Docker daemon is running
- Verify Jenkins user has Docker permissions

### Debug Commands
```bash
# Test SonarQube connection
curl -u YOUR_TOKEN: http://9.9.8.100196:9000/api/system/status

# Test Docker
docker --version
docker-compose --version

# Test network connectivity
ping 9.9.8.100196
```

## 9. Security Best Practices

1. **Use Jenkins Credentials**: Never hardcode secrets in pipeline
2. **Restrict Permissions**: Use role-based access control
3. **Regular Updates**: Keep Jenkins and plugins updated
4. **Backup Configuration**: Regularly backup Jenkins configuration
5. **Monitor Logs**: Check Jenkins logs for issues

## 10. Monitoring and Maintenance

### Health Checks
- Monitor Jenkins server health
- Check SonarQube server status
- Review pipeline execution times
- Monitor disk space usage

### Regular Maintenance
- Clean up old builds
- Update plugins regularly
- Review and rotate credentials
- Monitor system resources

## Support

If you encounter issues:
1. Check Jenkins logs: `/var/log/jenkins/jenkins.log`
2. Review pipeline console output
3. Verify all credentials are properly configured
4. Test individual components manually 