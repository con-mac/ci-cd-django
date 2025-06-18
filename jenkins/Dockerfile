FROM jenkins/jenkins:lts

USER root

# Install Docker CLI, Docker Compose, Java (for Dastardly), and unzip
RUN apt-get update && apt-get install -y \
    docker.io \
    openjdk-17-jre-headless \
    unzip \
 && rm -rf /var/lib/apt/lists/*

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# Install plugins (from plugins.txt)
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

# Install JCasC configuration
COPY casc.yaml /var/jenkins_home/casc.yaml

# Tell Jenkins where to find JCasC config
ENV CASC_JENKINS_CONFIG=/var/jenkins_home/casc.yaml

# Trivy (security scanner)
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin



# OWASP Dependency-Check CLI
ENV DEPENDENCY_CHECK_VERSION=9.0.10
RUN curl -L "https://github.com/jeremylong/DependencyCheck/releases/download/v${DEPENDENCY_CHECK_VERSION}/dependency-check-${DEPENDENCY_CHECK_VERSION}-release.zip" -o /tmp/dc.zip \
    && unzip /tmp/dc.zip -d /opt/dependency-check \
    && ln -s /opt/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check \
    && rm /tmp/dc.zip

USER jenkins
