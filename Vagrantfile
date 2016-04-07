# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = 'example.com'

puppet_nodes = [
  {:hostname => 'puppet',  :ip => '172.16.32.10', :box => 'ubuntu/wily64', :fwdhost => 8140, :fwdguest => 8140, :ram => 1028},
  {:hostname => 'client1', :ip => '172.16.32.11', :box => 'ubuntu/wily64'},
  {:hostname => 'client2', :ip => '172.16.32.12', :box => 'ubuntu/wily64'},
]

Vagrant.configure("2") do |config|
  puppet_nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box]
      node_config.vm.box_url = 'http://files.vagrantup.com/' + node_config.vm.box + '.box'
      node_config.vm.hostname = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]
      node_config.vm.synced_folder "storage/" "/storage"

      if node[:fwdhost]
        node_config.vm.network :forwarded_port, guest: node[:fwdguest], host: node[:fwdhost]
      end

      #if Vagrant.has_plugin?("vagrant-proxyconf")
      #  config.proxy.http     = "http://193.120.90.48:8080/"
      #  config.proxy.https    = "http://193.120.90.48:8080/"
      #  config.proxy.no_proxy = "localhost,127.0.0.1,.example.com"
      #end
      
      config.vm.provision "fix-no-tty", type: "shell" do |s|
        s.privileged = false
        s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
      end

      memory = node[:ram] ? node[:ram] : 384;
      node_config.vm.provider :virtualbox do |vb|
        vb.customize [
          'modifyvm', :id,
          '--name', node[:hostname],
          '--memory', memory.to_s
        ]
      end


      node_config.vm.provision :puppet do |puppet|
          puppet.module_path = 'environments/provision/modules'
      end
    end
  end
end
