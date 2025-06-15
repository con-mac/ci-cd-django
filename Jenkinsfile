pipeline {
    agent any

    environment {
        COMPOSE_FILES = "-f docker-compose.yml -f docker-compose.jenkins.yml"
        WORKDIR = "/var/jenkins_home/workspace/ci-cd-django-pipeline"
    }

    stages {
        stage('Build Docker Images') {
            steps {
                echo "🔧 Building Docker images for web and db..."
                dir("${env.WORKDIR}") {
                    sh "docker-compose ${COMPOSE_FILES} build web db"
                }
            }
        }

        stage('Run Migrations') {
            steps {
                echo "📦 Running Django database migrations..."
                dir("${env.WORKDIR}") {
                    sh "docker-compose ${COMPOSE_FILES} run --rm web python manage.py migrate"
                }
            }
        }

        stage('Start Django & DB Services') {
            steps {
                echo "🚀 Starting web and db services..."
                dir("${env.WORKDIR}") {
                    sh "docker-compose ${COMPOSE_FILES} up -d db web"
                }
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
    }
}
