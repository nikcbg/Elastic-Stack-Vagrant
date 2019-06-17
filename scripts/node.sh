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

#Installing nginx
sudo yum install nginx -y

#Installing vim editor
sudo yum install vim -y

#Installing wget.
sudo yum install wget -y
# Downloading rpm package of filebeat
sudo wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.2.3-x86_64.rpm 
# Install rpm package of filebeat
sudo rpm --install filebeat-6.2.3-x86_64.rpm 

sudo systemctl enable filebeat 

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
