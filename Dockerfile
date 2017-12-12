FROM emundo/docker-compose-openjdk-node:latest

RUN wget "https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778.zip"; \
    jar xf sonar-scanner-cli-3.0.3.778.zip; \
    rm sonar-scanner-cli-3.0.3.778.zip; \
    mv sonar-scanner-3.0.3.778 sonar-scanner; \
    rm sonar-scanner/**/*.bat; \
    mv sonar-scanner/bin/* /usr/local/bin; \
    mv sonar-scanner/lib/* /usr/local/lib; \
    rm sonar-scanner; \
    chmod +x /usr/local/bin/sonar-*
