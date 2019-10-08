# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.define "bastion" do |conf|
    conf.vm.box = "centos/7"
    conf.vm.hostname = "bastion"

    conf.vm.provision "ansible" do |ansible|
      ansible.groups = {
        "all" => [ "bastion" ],
        "bastion" => [ "bastion" ],
      }
      ansible.vault_password_file = ".ansible-password"
      ansible.playbook = "ansible/playbook.yml"
      # ansible.start_at_task = "common : install drive utils"
    end
  end

  config.vm.define "wordpress" do |conf|
    conf.vm.box = "centos/7"
    conf.vm.hostname = "wordpress"
    config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "forwarded_port", guest: 9000, host: 9000
    config.vm.network "forwarded_port", guest: 3306, host: 3306

    conf.vm.provision "ansible" do |ansible|
      ansible.groups = {
        "all" => [ "wordpress" ],
        "wordpress" => [ "wordpress" ],
        "cloud_sql_proxy" => [ "wordpress" ],
      }
      ansible.vault_password_file = ".ansible-password"
      ansible.playbook = "ansible/playbook.yml"
      # ansible.start_at_task = "install selinux libs"
    end
  end

  config.vm.define "lb" do |conf|
    conf.vm.box = "centos/7"
    conf.vm.hostname = "lb"
    config.vm.network "forwarded_port", guest: 80, host: 8081

    conf.vm.provision "ansible" do |ansible|
      ansible.groups = {
        "all" => [ "lb" ],
        "load_balancer" => [ "lb" ],
      }
      ansible.vault_password_file = ".ansible-password"
      ansible.playbook = "ansible/playbook.yml"
      # ansible.start_at_task = "common : install drive utils"
    end
  end
end
