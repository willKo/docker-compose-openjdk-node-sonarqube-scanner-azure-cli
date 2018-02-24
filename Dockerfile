FROM openjdk:latest

RUN apt-get update && apt-get install -y build-essential apt-transport-https ca-certificates curl gnupg2 software-properties-common tar

## Install Node
RUN curl -sL https://deb.nodesource.com/setup_9.x | sh
RUN apt-get install -y nodejs

## Docker Compose
RUN curl -sL https://github.com/docker/compose/releases/download/1.17.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose

## Docker
RUN curl -s https://download.docker.com/linux/static/stable/`uname -m`/docker-17.09.0-ce.tgz | tar xzvf - -C /usr/local/bin/ --strip-components=1

## PhantomJS
RUN curl -sL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 | tar xjvf - -C /usr/local/bin/ phantomjs-2.1.1-linux-x86_64/bin/phantomjs --strip-components=2

## Rancher Compose
RUN curl -L https://github.com/rancher/rancher-compose/releases/download/v0.12.5/rancher-compose-linux-amd64-v0.12.5.tar.xz | tar xJvf -  --strip-components=2 -C /usr/local/bin/ && chmod +x /usr/local/bin/rancher-compose

RUN wget "https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778.zip"; \
    jar xf sonar-scanner-cli-3.0.3.778.zip; \
    rm sonar-scanner-cli-3.0.3.778.zip; \
    mv sonar-scanner-3.0.3.778 sonar-scanner; \
    rm sonar-scanner/**/*.bat; \
    mv sonar-scanner/bin/* /usr/local/bin; \
    mv sonar-scanner/lib/* /usr/local/lib; \
    rm -rf sonar-scanner; \
    chmod +x /usr/local/bin/sonar-*

## CI User
RUN useradd -ms /bin/bash ci && adduser ci sudo
USER ci
WORKDIR /home/ci
