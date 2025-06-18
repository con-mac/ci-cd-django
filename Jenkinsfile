pipeline {
    agent any

    environment {
        COMPOSE_FILES = "-f docker-compose.yml -f docker-compose.jenkins.yml"
        WORKDIR = "/var/jenkins_home/workspace/ci-cd-django-pipeline"
    }

    stages {
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
                    sh "docker-compose ${COMPOSE_FILES} build web db"
                }
            }
        }

        stage('Wait for Database') {
            steps {
                echo "⏳ Starting database and waiting for it to be ready..."
                dir("${env.WORKDIR}") {
                    sh "docker-compose ${COMPOSE_FILES} up -d db"
                    sh "sleep 10"  // Give database time to start
                }
            }
        }

        stage('Debug: Confirm manage.py in Container') {
            steps {
                echo "🔍 Debug: Checking for manage.py inside container..."
                dir("${env.WORKDIR}") {
                    sh "docker-compose ${COMPOSE_FILES} run --rm web ls -l /usr/src/app"
                }
            }
        }

        stage('Run Migrations') {
            steps {
                echo "📦 Running Django database migrations..."
                dir("${env.WORKDIR}") {
                    sh """
                        docker-compose ${COMPOSE_FILES} run --rm \
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
                    sh "docker-compose ${COMPOSE_FILES} up -d web"
                }
            }
        }

        stage('Health Check') {
            steps {
                echo "🏥 Performing health check..."
                dir("${env.WORKDIR}") {
                    sh "sleep 5"  // Give web service time to start
                    sh "docker-compose ${COMPOSE_FILES} ps"
                }
            }
        }

        // --- DEVSECOPS TOOLING ---
        stage('Trivy: Container Vulnerability Scan') {
            steps {
                echo "🔒 Running Trivy scan on Django web image..."
                dir("${env.WORKDIR}") {
                    sh 'trivy image ci-cd-django-web:latest || true' // allow to continue if vulnerabilities are found
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


        stage('DevSecOps: DAST with Dastardly') {
            steps {
                echo "🔎 Running Dastardly DAST scan (Burp Suite Community)..."
                sh '''
                    curl -L "https://github.com/PortSwigger/dastardly/releases/latest/download/dastardly-linux-amd64.tar.gz" -o dastardly.tar.gz
                    mkdir -p dastardly
                    tar -xzvf dastardly.tar.gz -C dastardly
                    chmod +x dastardly/dastardly.sh
                    # Example scan command:
                    ./dastardly/dastardly.sh --url http://web:8000/
                '''
            }
        }


        
    }

    post {
        always {
            echo "🧹 Cleaning up containers and volumes (excluding Jenkins)..."
            dir("${env.WORKDIR}") {
                sh "docker-compose ${COMPOSE_FILES} stop db web || true"
                sh "docker-compose ${COMPOSE_FILES} rm -f db web || true"
                sh "docker volume prune -f || true"
            }
        }
        failure {
            echo "💥 Pipeline failed! Collecting logs..."
            dir("${env.WORKDIR}") {
                sh "docker-compose ${COMPOSE_FILES} logs web || true"
                sh "docker-compose ${COMPOSE_FILES} logs db || true"
            }
        }
    }
}
