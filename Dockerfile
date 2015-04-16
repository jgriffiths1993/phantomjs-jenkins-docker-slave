FROM debian:wheezy
MAINTAINER Joshua Griffiths <jgriffiths.1993@gmail.com>

ENV INITRD no
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

RUN ln -sf /bin/true /usr/bin/ischroot &&\
    ln -sf /bin/true /sbin/initctl

ADD bin/pidone /sbin/pidone

RUN apt-get -y --force-yes update &&\
    apt-get -y --force-yes install \
        python sudo openssh-server openssh-client syslog-ng \
        default-jdk logrotate tar runit git subversion gcc \
        build-essential g++ flex bison gperf ruby perl \
        libsqlite3-dev libfontconfig1-dev libicu-dev \
        libfreetype6 libssl-dev libpng-dev libjpeg-dev &&\
    mkdir /var/lib/syslog-ng &&\
    touch /var/log/syslog &&\
    chmod 640 /var/log/syslog &&\
    sed -i -e 's/^\(\s*\)system();/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf &&\
    useradd -ms/bin/bash jenkins &&\
    echo 'jenkins:jenkins' | chpasswd &&\
    echo 'jenkins ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers &&\
    git clone http://github.com/ariya/phantomjs.git &&\
    cd phantomjs &&\
    git checkout 1.9 &&\
    ./build.sh --confirm &&\
    cp bin/phantomjs /usr/local/bin/phantomjs &&\
    cd .. &&\
    rm -rf phantomjs

ADD config/syslog-ng-default /etc/default/syslog-ng
ADD config/logrotate.conf /etc/logrotate.conf
ADD config/sshd_config /etc/ssh/sshd_config
ADD config/ssh_config /etc/ssh/ssh_config
ADD runit /etc/service

EXPOSE 22
ENTRYPOINT ["/sbin/pidone"]
