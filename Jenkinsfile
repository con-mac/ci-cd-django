pipeline {
    agent any

    environment {
        COMPOSE_FILES = "-f docker-compose.yml -f docker-compose.jenkins.yml"
        WORKDIR = "/var/jenkins_home/workspace/ci-cd-django-pipeline"
        DOCKER_COMPOSE = "docker-compose"
        COMPOSE_OVERRIDE = "-f docker-compose.yml -f docker-compose.jenkins.yml"
        // SonarQube configuration
        SONAR_HOST_URL = "http://9.9.8.100196:9000"
        SONAR_PROJECT_KEY = "ci-cd-django"
        SONAR_PROJECT_NAME = "CI/CD Django"
    }

    // Automatic triggers - pipeline runs on:
    // 1. Every push to any branch
    // 2. Every pull request
    // 3. Manual trigger from Jenkins UI
    triggers {
        pollSCM('H/5 * * * *')  // Poll SCM every 5 minutes as fallback
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    // Use Jenkins credentials for SonarQube authentication
                    withCredentials([
                        string(credentialsId: 'SONARQUBE_TOKEN', variable: 'SONAR_TOKEN')
                    ]) {
                        // Create sonar-project.properties with authentication
                        sh """
                            cat > sonar-project.properties << EOF
                            sonar.projectKey=${SONAR_PROJECT_KEY}
                            sonar.projectName=${SONAR_PROJECT_NAME}
                            sonar.sources=.
                            sonar.language=py
                            sonar.sourceEncoding=UTF-8
                            sonar.host.url=${SONAR_HOST_URL}
                            sonar.login=${SONAR_TOKEN}
                            EOF
                        """
                        
                        // Run SonarQube analysis with proper authentication
                        withSonarQubeEnv('My SonarQube Server') {
                            sh 'sonar-scanner -Dsonar.login=${SONAR_TOKEN}'
                        }
                    }
                }
            }
            post {
                always {
                    // Archive SonarQube report if generated
                    archiveArtifacts artifacts: '**/sonar-report.html', allowEmptyArchive: true
                }
            }
        }
        
        stage('Dependency Scan (OWASP)') {
            steps {
                echo "🔒 Running OWASP Dependency-Check on source code..."
                dir("${env.WORKDIR}/app") {
                    sh 'dependency-check --project "django-app" --scan . --format "HTML,JSON" --out /var/jenkins_home/depcheck-report || true'
                }
            }
            post {
                always {
                    // Archive dependency check reports
                    archiveArtifacts artifacts: '/var/jenkins_home/depcheck-report/*.html,/var/jenkins_home/depcheck-report/*.json', allowEmptyArchive: true
                }
            }
        }
        
        stage('Build Docker Images') {
            steps {
                echo "🔧 Building Docker images for web and db..."
                dir("${env.WORKDIR}") {
                    sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} build --no-cache web db"
                }
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                echo "🔒 Running Trivy scan on Django web image..."
                dir("${env.WORKDIR}") {
                    sh 'trivy image ci-cd-django-pipeline-web:latest || true'
                }
            }
        }
        
        stage('Start Services') {
            steps {
                echo "⏳ Starting database and web service..."
                dir("${env.WORKDIR}") {
                    sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} up -d db web"
                    sh "sleep 10"  // Give services time to start
                }
            }
        }
        
        stage('Run Migrations') {
            steps {
                echo "📦 Running Django database migrations..."
                dir("${env.WORKDIR}") {
                    sh """
                        ${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} run --rm \
                        -w /usr/src/app \
                        web python manage.py migrate
                    """
                }
            }
        }
        
        stage('OWASP ZAP: DAST Scan') {
            steps {
                echo "🔒 Running OWASP ZAP DAST scan..."
                sh '''
                    sleep 10
                    docker run --network ci-cd-django-pipeline_default -t ghcr.io/zaproxy/zaproxy:stable zap-baseline.py -t http://web:8000/ -r zap-report.html || true
                '''
            }
            post {
                always {
                    // Archive ZAP report
                    archiveArtifacts artifacts: 'zap-report.html', allowEmptyArchive: true
                }
            }
        }
        
        stage('Generate SBOM (CycloneDX)') {
            steps {
                echo "📦 Generating SBOM with Trivy..."
                sh 'trivy image --format cyclonedx --output sbom-cyclonedx.json ci-cd-django-pipeline-web:latest'
                archiveArtifacts artifacts: 'sbom-cyclonedx.json', fingerprint: true
            }
        }
        
        stage('Upload SBOM to Dependency-Track') {
            steps {
                script {
                    // Only upload if Dependency-Track is available
                    try {
                        withCredentials([string(credentialsId: 'DT_API_KEY', variable: 'DT_API_KEY')]) {
                            sh '''
                                curl -X POST "http://localhost:8081/api/v1/bom" \
                                -H "X-Api-Key: $DT_API_KEY" \
                                -H "Content-Type: multipart/form-data" \
                                -F "projectName=ci-cd-django" \
                                -F "autoCreate=true" \
                                -F "bom=@sbom-cyclonedx.json"
                            '''
                        }
                    } catch (Exception e) {
                        echo "⚠️ Dependency-Track upload failed: ${e.getMessage()}"
                        // Don't fail the pipeline for this
                    }
                }
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up containers and volumes (excluding Jenkins)..."
            dir("${env.WORKDIR}") {
                sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} stop db web || true"
                sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} rm -f db web || true"
                sh "docker volume prune -f || true"
            }
        }
        
        failure {
            echo "💥 Pipeline failed! Collecting logs..."
            dir("${env.WORKDIR}") {
                sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} logs web || true"
                sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} logs db || true"
            }
            
            // Modern notification approach - Email notification
            emailext (
                subject: "❌ Pipeline Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <h2>Pipeline Failure Alert</h2>
                    <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                    <p><strong>Build:</strong> #${env.BUILD_NUMBER}</p>
                    <p><strong>Status:</strong> FAILED</p>
                    <p><strong>Duration:</strong> ${currentBuild.durationString}</p>
                    <p><strong>Console:</strong> <a href="${env.BUILD_URL}console">View Console</a></p>
                    <hr>
                    <p>Please check the build logs for more details.</p>
                """,
                recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                mimeType: 'text/html'
            )
            
            // Alternative: Webhook notification (if configured)
            script {
                try {
                    withCredentials([string(credentialsId: 'WEBHOOK_URL', variable: 'WEBHOOK_URL')]) {
                        sh """
                            curl -X POST "${WEBHOOK_URL}" \
                            -H "Content-Type: application/json" \
                            -d '{
                                "text": "❌ Pipeline Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                                "attachments": [{
                                    "title": "Build Details",
                                    "fields": [
                                        {"title": "Job", "value": "${env.JOB_NAME}", "short": true},
                                        {"title": "Build", "value": "#${env.BUILD_NUMBER}", "short": true},
                                        {"title": "Duration", "value": "${currentBuild.durationString}", "short": true},
                                        {"title": "Console", "value": "${env.BUILD_URL}console", "short": true}
                                    ]
                                }]
                            }'
                        """
                    }
                } catch (Exception e) {
                    echo "⚠️ Webhook notification failed: ${e.getMessage()}"
                }
            }
        }
        
        success {
            echo "✅ Pipeline succeeded!"
            
            // Success notification
            emailext (
                subject: "✅ Pipeline Succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <h2>Pipeline Success</h2>
                    <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                    <p><strong>Build:</strong> #${env.BUILD_NUMBER}</p>
                    <p><strong>Status:</strong> SUCCESS</p>
                    <p><strong>Duration:</strong> ${currentBuild.durationString}</p>
                    <p><strong>Console:</strong> <a href="${env.BUILD_URL}console">View Console</a></p>
                    <hr>
                    <p>All stages completed successfully!</p>
                """,
                recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                mimeType: 'text/html'
            )
            
            // Success webhook notification
            script {
                try {
                    withCredentials([string(credentialsId: 'WEBHOOK_URL', variable: 'WEBHOOK_URL')]) {
                        sh """
                            curl -X POST "${WEBHOOK_URL}" \
                            -H "Content-Type: application/json" \
                            -d '{
                                "text": "✅ Pipeline Succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                                "attachments": [{
                                    "title": "Build Details",
                                    "fields": [
                                        {"title": "Job", "value": "${env.JOB_NAME}", "short": true},
                                        {"title": "Build", "value": "#${env.BUILD_NUMBER}", "short": true},
                                        {"title": "Duration", "value": "${currentBuild.durationString}", "short": true},
                                        {"title": "Console", "value": "${env.BUILD_URL}console", "short": true}
                                    ]
                                }]
                            }'
                        """
                    }
                } catch (Exception e) {
                    echo "⚠️ Webhook notification failed: ${e.getMessage()}"
                }
            }
        }
        
        unstable {
            echo "⚠️ Pipeline is unstable!"
            
            // Unstable notification
            emailext (
                subject: "⚠️ Pipeline Unstable: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: """
                    <h2>Pipeline Unstable</h2>
                    <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                    <p><strong>Build:</strong> #${env.BUILD_NUMBER}</p>
                    <p><strong>Status:</strong> UNSTABLE</p>
                    <p><strong>Duration:</strong> ${currentBuild.durationString}</p>
                    <p><strong>Console:</strong> <a href="${env.BUILD_URL}console">View Console</a></p>
                    <hr>
                    <p>Some tests failed or quality gates were not met.</p>
                """,
                recipientProviders: [[$class: 'DevelopersRecipientProvider']],
                mimeType: 'text/html'
            )
        }
    }
}
