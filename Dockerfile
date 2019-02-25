FROM openjdk:8

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y apt-transport-https lsb-release software-properties-common dirmngr

# add azure to sources list
RUN AZ_REPO=$(lsb_release -cs) &&\
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list
# get microsoft signing key
RUN apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv \
     --keyserver packages.microsoft.com \
     --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF
# install azure cli
RUN  apt-get update &&\
     apt-get install azure-cli

# add Node.js source
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key \
        | apt-key add - \
    && sh -c 'echo "deb https://deb.nodesource.com/node_10.x stretch main" > /etc/apt/sources.list.d/nodesource.list' \
    && sh -c 'echo "deb-src https://deb.nodesource.com/node_10.x stretch main" >> /etc/apt/sources.list.d/nodesource.list' \
    && apt-get update -o Dir::Etc::sourcelist="sources.list.d/nodesource.list" \
        -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"

# add Google Chrome source
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub \
        | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update -o Dir::Etc::sourcelist="sources.list.d/google.list" \
        -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"


# install other dependencies
RUN apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        google-chrome-unstable \
        gnupg2 \
        nodejs \
        software-properties-common \
        tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH "$PATH:/opt/google/chrome-unstable/"

RUN npm install -g npm@latest \
    && npm cache clean --force

## Docker Compose
RUN curl -sL https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

## Docker
RUN curl -s https://download.docker.com/linux/static/stable/`uname -m`/docker-17.12.1-ce.tgz \
    | tar xzvf - -C /usr/local/bin/ --strip-components=1

## PhantomJS, deprecated - remove when all builds have migrated to ChromeHeadless
RUN curl -sL https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
    | tar xjvf - -C /usr/local/bin/ phantomjs-2.1.1-linux-x86_64/bin/phantomjs --strip-components=2

## Rancher Compose
RUN curl -L https://github.com/rancher/rancher-compose/releases/download/v0.12.5/rancher-compose-linux-amd64-v0.12.5.tar.xz \
    | tar xJvf -  --strip-components=2 -C /usr/local/bin/ \
    && chmod +x /usr/local/bin/rancher-compose

RUN wget \
        "https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.2.0.1227.zip" \
        -O ./sonar-scanner.zip; \
    jar xf sonar-scanner.zip; \
    mv sonar-scanner-* sonar-scanner; \
    rm sonar-scanner.zip; \
    rm sonar-scanner/**/*.bat; \
    mv sonar-scanner/bin/* /usr/local/bin; \
    mv sonar-scanner/lib/* /usr/local/lib; \
    rm -rf sonar-scanner; \
    chmod +x /usr/local/bin/sonar-*

## emundo User
RUN addgroup --gid 1101 rancher \
    # Für RancherOS brauchen wir diese Gruppe: http://rancher.com/docs/os/v1.1/en/system-services/custom-system-services/#creating-your-own-console
    && addgroup --gid 999 aws \
    # Für die AWS brauchen wir diese Gruppe
    && groupadd -r emundo \
    && useradd -rms /bin/bash \
        -g emundo \
        -G audio,aws,rancher,sudo,video \
        emundo \
    # FIXME Das ist notwendig, damit das Image lokal funktioniert
    && usermod -aG root emundo \
    && mkdir -p /home/emundo/Downloads

USER emundo
WORKDIR /home/emundo
