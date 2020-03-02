FROM centos:7.3.1611

ARG DOCKER_VERSION=17.06.0.ce-1.el7.centos


RUN yum-config-manager --setopt '*.exclude=git' --save \
  && yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo \
  && yum-config-manager --add-repo http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo \
  && yum -y update \
  && yum -y install docker-ce zip unzip apache-maven python3-devel gcc gzip tar

# Set CEST timezone
RUN unlink /etc/localtime && \
 ln -s /usr/share/zoneinfo/Europe/Berlin /etc/localtime\

RUN set -eux; \
        yum install -y \
                \
                freetype fontconfig \
        ; \
        rm -rf /var/cache/yum

ENV JAVA_HOME /usr/java/openjdk-11
ENV PATH $JAVA_HOME/bin:$PATH

# https://jdk.java.net/
ENV JAVA_VERSION 11.0.2
ENV JAVA_URL https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
ENV JAVA_SHA256 99be79935354f5c0df1ad293620ea36d13f48ec3ea870c838f20c504c9668b57

RUN set -eux; \
        \
        curl -fL -o /openjdk.tgz "$JAVA_URL"; \
        echo "$JAVA_SHA256 */openjdk.tgz" | sha256sum -c -; \
        mkdir -p "$JAVA_HOME"; \
        tar --extract --file /openjdk.tgz --directory "$JAVA_HOME" --strip-components 1; \
        rm /openjdk.tgz; \
        \
        ln -sfT "$JAVA_HOME" /usr/java/default; \
        ln -sfT "$JAVA_HOME" /usr/java/latest; \
        \
        java -Xshare:dump; \
        \
# basic smoke test
        java --version; \
        javac --version


RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" \
  && python get-pip.py \
  && pip install -r https://github.com/radsch/base/blob/master/requirements.txt

RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" \
  && python get-pip.py \
RUN python -m pip install aws-mfa \
  && python -m pip install awscli

#Install git
RUN yum install -y centos-release-scl && \
    yum install -y  https://centos7.iuscommunity.org/ius-release.rpm && \
    yum install git2u-all -y

# Install openshift cli, docker-compose, vault cli
RUN mkdir /oc \
 && curl -L https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz \
  | tar -xzf - --strip 1 -C /oc \
 && chmod +x /oc/oc \
 && pip install docker-compose \
 && curl https://releases.hashicorp.com/vault/0.9.0/vault_0.9.0_linux_amd64.zip \
  | jar x \
 && chmod +x ./vault \
 && mkdir /opt/vault \
 && mv ./vault /opt/vault/ \
 && mkdir /opt/jq \
 && curl -Ls https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /opt/jq/jq \
 && chmod +x /opt/jq/jq \
 && curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
 && chmod +x ./kubectl \
 && mv ./kubectl /usr/local/bin/kubectl \ 
 && curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && ./aws/install \
 && curl -LO https://get.helm.sh/helm-v3.0.2-linux-386.tar.gz \
 && tar -zxvf helm-v3.0.2-linux-386.tar.gz \
 && mv linux-386/helm /usr/local/bin/helm3 \
 && curl -LO https://get.helm.sh/helm-v2.16.0-linux-386.tar.gz \
 && tar -zxvf helm-v2.16.0-linux-386.tar.gz \
 && mv linux-386/helm /usr/local/bin/helm



ENV PATH=${PATH}:/oc:/opt/vault:/opt/jq

