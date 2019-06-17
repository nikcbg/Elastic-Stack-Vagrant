Vagrant.configure("2") do |config|

  config.vm.define vm_name="master" do |node|
    node.vm.network "forwarded_port", guest: 5601, host:5602
    node.vm.box = "centos/7"
    node.vm.hostname = vm_name  
    node.vm.network "private_network", ip: "192.168.1.10"
    node.vm.provision "shell", path: "scripts/master.sh"
    node.vm.provision "file", source: "conf/elasticsearch.yml", destination: "scripts/master.sh"
    node.vm.provider :virtualbox do |vb|
      vb.name = "master"
    end
  end
  config.vm.define vm_name="node" do |node|
    node.vm.network "forwarded_port", guest: 80, host:8080
    node.vm.box = "centos/7"
    node.vm.hostname = vm_name
    node.vm.network "private_network", ip: "192.168.1.11"
    node.vm.provision "shell", path: "scripts/node.sh"
    node.vm.provision "file", source: "conf/filebeat.yml",  destination: "scripts/node.sh"
    node.vm.provider :virtualbox do |vb|
      vb.name = "node"
    end
  end
end
