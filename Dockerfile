# Use the official Jenkins LTS image with Java 21.
FROM jenkins/jenkins:lts-jdk21

# Temporarily become root only while installing the Docker command-line tools.
USER root

# Install packages needed to configure Docker's signed package repository.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" \
        > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce-cli \
        docker-buildx-plugin \
        docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Install the Jenkins plugins required by the pipeline.
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator \
    git \
    credentials-binding \
    docker-workflow \
    pipeline-stage-view \
    junit \
    warnings-ng \
    ws-cleanup

# Run Jenkins using its standard unprivileged account.
USER jenkins
