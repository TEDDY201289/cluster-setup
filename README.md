# cluster-setup (via vagrent)
install vagrant in our PC as below (line 4 to 88)
# -*- mode: ruby -*-
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  config.vm.define "ubuntu-cka" do |vm1|
    config.ssh.private_key_path = "/Users/teddyyekyawthu/hashibox-arm/.ssh/id_rsa"
    config.ssh.forward_agent = true
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"
    vm1.vm.hostname = "control-plane"
    vm1.vm.box = "bento/ubuntu-22.04-arm64"
    vm1.vm.network "private_network", ip: "192.168.90.87", :name=> "vmnet5"
    # vm1.vm.network "forwarded_port", guest: 8200, host: 8200
    vm1.vm.synced_folder ".", "/home/vagrant/"
    vm1.vm.provider "vmware_fusion" do |vmware|
      vmware.gui = true
      #vmware.name = "ubuntu-cka"
      vmware.memory = "4096"
      vmware.cpus = 4
      vmware.gui = false
    end
  end

  config.vm.define "ubuntu-cka1" do |vm2|
    config.ssh.private_key_path = "/Users/teddyyekyawthu/hashibox-arm/.ssh/id_rsa"
    config.ssh.forward_agent = true
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"
    vm2.vm.hostname = "worker-1"
    vm2.vm.box = "bento/ubuntu-22.04-arm64"
    vm2.vm.network "private_network", ip: "192.168.90.88", :name=> "vmnet5"
    # vm1.vm.network "forwarded_port", guest: 8200, host: 8200
    vm2.vm.synced_folder ".", "/home/vagrant/"
    vm2.vm.provider "vmware_fusion" do |vmware|
      vmware.gui = true
      #vmware.name = "ubuntu-cka1"
      vmware.memory = "4096"
      vmware.cpus = 4
      vmware.gui = false
    end
  end

  config.vm.define "ubuntu-cka2" do |vm3|
    config.ssh.private_key_path = "/Users/teddyyekyawthu/hashibox-arm/.ssh/id_rsa"
    config.ssh.forward_agent = true
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"
    vm3.vm.hostname = "worker-2"
    vm3.vm.box = "bento/ubuntu-22.04-arm64"
    vm3.vm.network "private_network", ip: "192.168.90.89", :name=> "vmnet5"
    # vm1.vm.network "forwarded_port", guest: 8200, host: 8200
    vm3.vm.synced_folder ".", "/home/vagrant/"
    vm3.vm.provider "vmware_fusion" do |vmware|
      vmware.gui = true
      #vmware.name = "ubuntu-cka2"
      vmware.memory = "4096"
      vmware.cpus = 4
      vmware.gui = false
    end
  end

  # config.vm.define "ubuntu-cka3" do |vm4|
  #   config.ssh.private_key_path = "/Users/teddyyekyawthu/hashibox-arm/.ssh/id_rsa"
  #   config.ssh.forward_agent = true
  #   config.ssh.username = "vagrant"
  #   config.ssh.password = "vagrant"
  #   vm4.vm.hostname = "ubuntu-cka3"
  #   vm4.vm.box = "bento/ubuntu-22.04-arm64"
  #   vm4.vm.network "private_network", ip: "192.168.90.90", :name=> "vmnet5"
  #   # vm1.vm.network "forwarded_port", guest: 8200, host: 8200
  #   vm4.vm.synced_folder ".", "/home/vagrant/"
  #   vm4.vm.provider "vmware_fusion" do |vmware|
  #     vmware.gui = true
  #     #vmware.name = "ubuntu-cka2"
  #     vmware.memory = "8192"
  #     vmware.cpus = 2
  #     vmware.gui = false
  #   end
  # end
    #vm1.vm.provision "shell", run: "always", inline: <<-SHELL
      #sudo apt-get update
      #sudo apt-get install net-tools zip curl jq tree unzip wget siege apt-transport-https ca-certificates software-properties-common gnupg lsb-release -y
      #netstat -tunlp
      #echo "Hello from ubuntu-cka"
    #SHELL
  #end
end

#(Implementing Kubenertes clusters in Vagrant) 
after installing (1 control-plane and 2 worker nodes)
login in to each of Vagrant (by using vagrant ssh command)
then, assign host ip at this path(#sudo vi /etc/hosts)
add the nodes IP on each of Vagrant (To communicate nodes to nodes and joint the cluster purpose)
192.168.90.87 control-plane
192.168.90.88 worker-1
192.168.90.89 worker-2

then access to Vagrant 1, 2, 3 (control-plane, worker-1 , worker-2)

in control plane vagrant - Run this command to set up master-node ( ./control-plane-latest.sh or ./control-plane.sh)
control-plane.sh = Kube version 1.30 and control-plane-latest.sh = Kube version 1.33
after setting up is completed , use this command below in control-plane node
# kubeadm token create --print-join-command (Token-create-to-join-the-cluster)
# kubeadm token create --print-join-command
the same flow for worker nodes too. (worker.sh or worker-latest.sh)
then in each of worker node , run the comamnd for joint master nodes
# kubeadm join 192.168.90.87:6443 --token <your-token> \
    --discovery-token-ca-cert-hash sha256:<your-hash>
# sudo kubeadm join 192.168.90.87:6443 --token abcdef.0123456789abcdef \
    --discovery-token-ca-cert-hash sha256:1234567890abcdef...

# kubectl get nodes
