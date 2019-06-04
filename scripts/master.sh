# Checking whether user has enough permission to run this script
sudo -n true
if [ $? -ne 0 ]
    then
        echo "This script requires user to have passwordless sudo access"
        exit
fi

dependency_check_deb() {
java -version
if [ $? -ne 0 ]
    then
        # Installing Java 8 if it's not installed
        sudo wget --directory-prefix=/opt/ -nv --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz
        sudo tar xzf /opt/jdk-8u161-linux-x64.tar.gz -C /opt/
        sudo update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_161/bin/java 1
        sudo update-alternatives --config java <<< '1' 
        sudo -E echo -n -e '
        JAVA_HOME="/usr/java/jdk1.8.0_161/bin/java"
        JRE_HOME="/usr/java/jdk1.8.0_161/jre/bin/java"
        PATH=$PATH:$HOME/bin:JAVA_HOME:JRE_HOME' >> /etc/environment
        sudo -E source /etc/environment

fi
}

dependency_check_rpm() {
    java -version
    if [ $? -ne 0 ]
        then
            #Installing Java 8 if it's not installed
            sudo wget --directory-prefix=/opt/ -nv --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u161-b12/2f38c3b165be4555a1fa6e98c45e0808/jdk-8u161-linux-x64.tar.gz
            sudo tar xzf /opt/jdk-8u161-linux-x64.tar.gz -C /opt/
            sudo alternatives --install /usr/bin/java java /opt/jdk1.8.0_161/bin/java 1
            sudo alternatives --config java <<< '1'
            sudo -E echo -n -e '
            JAVA_HOME="/usr/java/jdk1.8.0_161/bin/java"
            JRE_HOME="/usr/java/jdk1.8.0_161/jre/bin/java"
            PATH=$PATH:$HOME/bin:JAVA_HOME:JRE_HOME' >> /etc/bashrc
    fi
}


rpm_elk() {
    #Installing wget.
    #sudo yum install wget -y
    # Downloading rpm package of elasticsearch
    sudo wget --directory-prefix=/tmp/ https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.2.4.rpm
    # Install rpm package of elasticsearch
    sudo rpm -ivh /tmp/elasticsearch-6.2.4.rpm
    # Downloading rpm package of logstash
    sudo wget --directory-prefix=/tmp/ https://artifacts.elastic.co/downloads/logstash/logstash-6.2.4.rpm
    # Install logstash rpm package
    sudo rpm -ivh /tmp/logstash-6.2.4.rpm
    # Download kibana tarball in /tmp
    sudo wget --directory-prefix=/tmp/ https://artifacts.elastic.co/downloads/kibana/kibana-6.2.4-x86_64.rpm
    # Install rpm package of kibana
    sudo rpm -ivh /tmp/kibana-6.2.4-x86_64.rpm
    # Starting The Services
    sudo systemctl daemon-reload
    sudo systemctl enable elasticsearch.service
    sudo systemctl enable logstash.service
    sudo systemctl enable kibana.service
    sudo systemctl restart elasticsearch.service
    sudo systemctl restart logstash.service
    sudo systemctl restart kibana.service
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

# Installing ELK Stack
if [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]
    then
        echo " It's a Debian based system"
        dependency_check_deb
        debian_elk
        firewall_elk_deb
        
elif [ "$(grep -Ei 'fedora|redhat|centos' /etc/*release)" ]
    then
        echo "It's a RedHat based system."
        dependency_check_rpm
        rpm_elk
        firewall_elk_rpm
else
    echo "This script doesn't support ELK installation on this OS."
fi
