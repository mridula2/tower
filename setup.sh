#!/bin/bash

#bash <(curl -s https://raw.github.hpe.com/oscar-romero/Tower/master/setup.sh)

echo '''export http_proxy=http://proxy.houston.hpecorp.net:8080
export https_proxy=http://proxy.houston.hpecorp.net:8080
export HTTP_PROXY=http://proxy.houston.hpecorp.net:8080
export HTTPS_PROXY=http://proxy.houston.hpecorp.net:8080
export no_proxy="localhost,127.0.0.1,hpecorp.net"
export NO_PROXY="localhost,127.0.0.1,hpecorp.net"
''' >> /etc/environment

source /etc/environment

yum remove epel-release -y

yum clean all && rm -fr /var/cache/yum/*

yum repolist

yum update -y

yum install http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y

yum update -y

yum install ansible wget curl git python-psycopg2 python-setuptools libselinux-python setools-libs yum-utils sudo acl -y

# Clone the Tower repo
git clone https://github.hpe.com/oscar-romero/Tower.git && cd Tower

./dependencies.sh

ansible-playbook -i inventory.yaml playbooks/tower-setup.yaml
