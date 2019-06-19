#!/bin/bash

# Checking whether user has enough permission to run this script
sudo -n true
if [ $? -ne 0 ]
    then
        echo "This script requires user to have passwordless sudo access"
        exit
fi

dependency_check_rpm() {
    java -version
    if [ $? -ne 0 ]
        then
            #Installing Java 8 if it's not installed
            sudo yum install jre-1.8.0-openjdk -y
        # Checking if java installed is less than version 7. If yes, installing Java 8. As logstash & Elasticsearch require Java 7 or later.
        elif [ "`java -version 2> /tmp/version && awk '/version/ { gsub(/"/, "", $NF); print ( $NF < 1.8 ) ? "YES" : "NO" }' /tmp/version`" == "YES" ]
            then
                sudo yum install jre-1.8.0-openjdk -y
    fi
}

#Installing vim editor
sudo yum install vim -y

rpm_elk() {
    #Installing wget.
    sudo yum install wget -y
    # Downloading rpm package of logstash
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/logstash/logstash-6.0.0-rc2.rpm
    # Install logstash rpm package
    sudo rpm -ivh /opt/logstash-6.0.0-rc2.rpm
    # Downloading rpm package of elasticsearch
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0-rc2.rpm
    # Install rpm package of elasticsearch
    sudo rpm -ivh /opt/elasticsearch-6.0.0-rc2.rpm
    # Download kibana tarball in /opt
    sudo wget --directory-prefix=/opt/ https://artifacts.elastic.co/downloads/kibana/kibana-6.0.0-rc2-linux-x86_64.tar.gz
    # Extracting kibana tarball
    sudo tar zxf /opt/kibana-6.0.0-rc2-linux-x86_64.tar.gz -C /opt/
    # Starting The Services
    sudo service logstash start
    sudo service elasticsearch start
    sudo /opt/kibana-6.0.0-rc2-linux-x86_64/bin/kibana &
}


firewall_elk_rpm() {
    #Setup firewall rules
    sudo firewall-cmd --permanent --zone=public --add-port=5601/tcp 
    sudo firewall-cmd --permanent --zone=public --add-port=9200/tcp 
    sudo firewall-cmd --permanent --zone=public --add-port=9300/tcp
    sudo firewall-cmd --permanent --zone=public --add-port=5044/tcp
    sudo firewall-cmd --reload
    #Test APP
    curl -X GET http://localhost:9200
    curl -X GET http://localhost:5601
}


