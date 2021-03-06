FROM xebia/centos7-systemd:latest
MAINTAINER nicolas.belan@gmail.com

LABEL network.b2.version="1.0.0"
LABEL vendor="B2 Network"
LABEL network.b2.release-date="2017-06-01"
LABEL network.b2.version.is-production="0"

ARG ENVIRONMENT
ARG CLIENT_CERT

RUN groupadd puppet
RUN useradd -g puppet puppet
RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
RUN yum -y --nogpgcheck install which hostname tar puppet-agent

COPY start.sh /start.sh
COPY puppetclient/master.conf /master.conf

ENV PATH /opt/puppetlabs/bin/:$PATH
ENV ENVIRONMENT ${ENVIRONMENT}
ENV CLIENT_CERT ${CLIENT_CERT}

RUN echo "/start.sh '$ENVIRONMENT' '$CLIENT_CERT'" > /etc/rc.local
RUN chmod /etc/rc.local 755

CMD ["/usr/sbin/init"]
