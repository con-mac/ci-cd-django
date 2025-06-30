pipeline {
    agent any

    environment {
        COMPOSE_FILES = "-f docker-compose.yml -f docker-compose.jenkins.yml"
        WORKDIR = "/var/jenkins_home/workspace/ci-cd-django-pipeline"
        DOCKER_COMPOSE = "docker-compose"
        COMPOSE_OVERRIDE = "-f docker-compose.yml -f docker-compose.jenkins.yml"
    }

    stages {
        stage('Cleanup: Remove Existing Containers and Images') {
            steps {
                echo "🧹 Cleaning up existing containers and images..."
                dir("${env.WORKDIR}") {
                    sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} down --remove-orphans || true"
                    sh "docker stop django-web || true"
                    sh "docker rm django-web || true"
                    sh "docker stop ci-cd-django-pipeline-db-1 || true"
                    sh "docker rm ci-cd-django-pipeline-db-1 || true"
                    sh "docker rmi ci-cd-django-pipeline-web:latest || true"
                    sh "docker rmi ci-cd-django-pipeline-db-1 || true"
                }
            }
        }

        stage('Debug: Confirm Jenkins Workspace and Code') {
            steps {
                echo "🔍 Debug: Checking workspace content before build..."
                dir("${env.WORKDIR}") {
                    sh "pwd"
                    sh "ls -al"
                    sh "ls -al app"
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

        stage('Wait for Database') {
            steps {
                echo "⏳ Starting database and waiting for it to be ready..."
                dir("${env.WORKDIR}") {
                    sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} up -d db"
                    sh "sleep 10"  // Give database time to start
                }
            }
        }

        stage('Debug: Confirm manage.py in Container') {
            steps {
                echo "🔍 Debug: Checking for manage.py inside container..."
                dir("${env.WORKDIR}") {
                    sh "pwd"
                    sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} config"
                    sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} run --rm web ls -la /usr/src/app/"
                    sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} run --rm web find /usr/src/app -name 'manage.py' -type f"
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

        stage('Start Django Service') {
            steps {
                echo "🚀 Starting web service..."
                dir("${env.WORKDIR}") {
                    sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} up -d web"
                }
            }
        }

        stage('Health Check') {
            steps {
                echo "🏥 Performing health check..."
                dir("${env.WORKDIR}") {
                    sh "sleep 5"  // Give web service time to start
                    sh "${DOCKER_COMPOSE} ${COMPOSE_OVERRIDE} ps"
                }
            }
        }

        // --- DEVSECOPS TOOLING ---
        stage('Trivy: Container Vulnerability Scan') {
            steps {
                echo "🔒 Running Trivy scan on Django web image..."
                dir("${env.WORKDIR}") {
                    sh 'trivy image ci-cd-django-pipeline-web:latest || true' // allow to continue if vulnerabilities are found
                }
            }
        }

        stage('OWASP Dependency-Check: Python Package Scan') {
            steps {
                echo "🔒 Running OWASP Dependency-Check on source code..."
                dir("${env.WORKDIR}/app") {
                    sh 'dependency-check --project "django-app" --scan . --format "HTML,JSON" --out /var/jenkins_home/depcheck-report || true'
                }
            }
        }

        stage('OWASP ZAP: DAST Scan') {
            steps {
                echo "🔒 Running OWASP ZAP DAST scan..."
                sh '''
                    # Wait for the web service to be up (adjust as needed)
                    sleep 10
                    # Run ZAP baseline scan against the Django web app
                    docker run --network ci-cd-django-pipeline_default -t owasp/zap2docker-stable zap-baseline.py -t http://web:8000/ -r zap-report.html || true
                '''
            }
        }

        stage('Generate SBOM (CycloneDX)') {
            steps {
                echo "📦 Generating SBOM with Trivy..."
                sh '''
                    trivy image --format cyclonedx --output sbom-cyclonedx.json ci-cd-django-pipeline-web:latest
                '''
                // Optionally, archive the SBOM as a Jenkins artifact
                archiveArtifacts artifacts: 'sbom-cyclonedx.json', fingerprint: true
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
        }
    }
}
