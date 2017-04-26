FROM centos:7
MAINTAINER nicolas.belan@gmail.com

RUN groupadd puppet
RUN useradd -g puppet puppet
RUN rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
RUN yum -y install which hostname tar puppet-agent
ADD start.sh /start.sh
ADD puppetclient/master.conf /master.conf

ENV PATH /opt/puppetlabs/bin/:$PATH
CMD /start.sh

