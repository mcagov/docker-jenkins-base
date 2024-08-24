FROM 009543623063.dkr.ecr.eu-west-2.amazonaws.com/jdk:corretto-21

# need to ensure jenkins has the same uid/gid as the ec2 version
ARG docker_gid=1000
ARG jenkins_uid=1000
ARG jenkins_gid=1001
ARG COMPOSE_VERSION="2.23.1"
ARG BUILDX_VERSION="0.12.0"
ARG DOCKER_PLUGINS="/usr/local/lib/docker/cli-plugins"

# create jenkins user
# install devtools and docker
# install awscli v2
# configure ecr-credential helper

COPY config.json /tmp/config.json
COPY --from=docker:dind /usr/local/bin/docker /usr/local/bin/

RUN groupadd -g  ${docker_gid} docker && \
  groupadd -g  ${jenkins_gid} jenkins && \
  useradd -u ${jenkins_uid} -g ${jenkins_gid} -m -s /bin/bash jenkins && \
  usermod -a -G docker jenkins && \
  dnf install -y amazon-ecr-credential-helper findutils git jq unzip which zip && \
  dnf clean all && \
  rm -rf /var/cache/yum && \
  mkdir -p "${DOCKER_PLUGINS}" && \
  curl -SL https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-x86_64 \
          -o "${DOCKER_PLUGINS}/docker-compose" && \
  curl -SL https://github.com/docker/buildx/releases/download/v${BUILDX_VERSION}/buildx-v${BUILDX_VERSION}.linux-amd64 \
          -o "${DOCKER_PLUGINS}/docker-buildx" && \
  chmod +x "${DOCKER_PLUGINS}"/docker-* && \
  curl -SL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
         -o awscliv2.zip && \
  unzip -q awscliv2.zip && \
  ./aws/install && \
  rm -rf aws awscliv2.zip && \
  mkdir -p /home/jenkins/.docker/ && \
  mv /tmp/config.json /home/jenkins/.docker/config.json && \
  chown -R ${jenkins_uid}:${jenkins_gid} /home/jenkins/ && \
  dnf clean all && \
  rm -rf /var/cache/yum && \
  rm -rf /tmp/*

USER jenkins
WORKDIR /home/jenkins
CMD ["/bin/bash"]
