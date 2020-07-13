FROM jenkins/jenkins:lts

ARG COMPOSE_VERSION=1.26.2

ENV JENKINS_USER admin
ENV JENKINS_PASS admin#123

ENV JENKINS_OPTS --prefix=/jenkins

# Skip initial setup
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

USER root
RUN apt-get update -qq \
    && apt-get install -qqy apt-transport-https ca-certificates curl gnupg-agent software-properties-common \
    && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

RUN apt-get update  -qq \
    && apt-get install docker-ce -y \
    && curl -s -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o \
        /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && usermod -aG docker jenkins \
    && apt-get clean

USER jenkins

COPY jenkins-plugins.txt /usr/share/jenkins/jenkins-plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/jenkins-plugins.txt

#COPY init_scripts_jenkins/* /usr/share/jenkins/ref/init.groovy.d/