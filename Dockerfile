FROM jenkins/jenkins:lts

ARG DOCKER_COMPOSE_VERSION=v2.21.0

USER root

# Обновление и установка необходимых пакетов
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    git \
    software-properties-common && \
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add - && \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable" && \
    apt-get update && \
    apt-get -y install docker-ce && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Установка Docker Compose
RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Установка Docker Buildx
RUN mkdir -p ~/.docker/cli-plugins/ && \
    DOCKER_BUILDX_VERSION=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    curl -L -o ~/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/${DOCKER_BUILDX_VERSION}/buildx-${DOCKER_BUILDX_VERSION}.linux-amd64 && \
    chmod a+x ~/.docker/cli-plugins/docker-buildx

RUN usermod -aG docker jenkins && gpasswd -a jenkins docker

USER jenkins