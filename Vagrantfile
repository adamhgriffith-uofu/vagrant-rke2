# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 2.4.0"

# Load Ruby Gems:
require 'yaml'

# Environmental Variables:
ENV['SETTINGS_PATH'] = "./settings.yml"

# Load settings from file:
settings = YAML.load_file(ENV['SETTINGS_PATH'])
servers = settings['servers']

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Avoid updating the guest additions if the user has the plugin installed:
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  # Display a note when running the machine.
  config.vm.post_up_message = "Remember, switch to root shell before running K8s commands!"

  # Share an additional folder to the guest VM.
  config.vm.synced_folder "./work", "/vagrant_work", SharedFoldersEnableSymlinksCreate: false

  ##############################################################
  # Create the nodes.                                          #
  ##############################################################
  servers.each_with_index do |server, index|

    config.vm.define server['name'] do |node|

      node.vm.box = "bento/rockylinux-9"
      node.vm.box_version = "202404.23.0"
      node.vm.hostname = server['name']

      # VirtualBox Provider
      node.vm.provider "virtualbox" do |vb|
        # Customize the number of CPUs on the VM:
        vb.cpus = 2

        # Customize the network drivers:
        vb.default_nic_type = "virtio"

        # Display the VirtualBox GUI when booting the machine:
        vb.gui = false

        # Customize the amount of memory on the VM:
        vb.memory = 8192

        # Customize the name that appears in the VirtualBox GUI:
        vb.name = server['name']
      end
      
      if index < 1
        # Perform housekeeping on `vagrant destroy` of the control-plane (a.k.a. master) node..
        node.trigger.before :destroy do |trigger|
          trigger.warn = "Performing housekeeping before starting destroy..."
          trigger.run_remote = {
            path: "./scripts/cluster/housekeeping.sh"
          }
        end
      end

      # Provision with shell scripts.
      node.vm.provision "shell" do |script|
        script.env = {
            IPV4_ADDR: server['ipv4'],
            IPV4_MASK: server['ipv4_mask'],
            IPV4_GW: server['ipv4_gw'],
            SEARCH_DOMAINS: server['search_domains']
        }
        script.path = "./scripts/os-requirements.sh"
      end

      if index < 1 # The server node(s)
        node.vm.provision "shell" do |script|
          script.env = {}
          script.path = "./scripts/cluster/get-rke2.sh"
          script.privileged = true
        end

        node.vm.provision "shell" do |script|
          script.env = {}
          script.path = "./scripts/cluster/server.sh"
          script.privileged = true
        end
      else # The agent node(s)
        node.vm.provision "shell" do |script|
          script.env = {
            INSTALL_RKE2_TYPE: "agent"
          }
          script.path = "./scripts/cluster/get-rke2.sh"
          script.privileged = true
        end

        node.vm.provision "shell" do |script|
          script.env = {
            RKE2_SERVER: servers[0]['name']
          }
          script.path = "./scripts/cluster/agent.sh"
          script.privileged = true
        end
      end
    end
  end
end