Vagrant.configure("2") do |config|

  config.vm.define vm_name="master" do |node|
    node.vm.network "forwarded_port", guest: 5601, host:5601
    node.vm.box = "centos/7"
    node.vm.hostname = vm_name  
    node.vm.network "private_network", ip: "192.168.56.10"
    node.vm.provision "shell", path: "scripts/master.sh"
end
  config.vm.define vm_name="node1" do |node|
    node.vm.network "forwarded_port", guest: 80, host:8080
    node.vm.box = "centos/7"
    node.vm.hostname = vm_name
    node.vm.network "private_network", ip: "192.168.56.11"
   #node.vm.provision "shell", path: "scripts/node.sh"

end

end
