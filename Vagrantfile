# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_NAME = ENV['BOX_NAME'] || "docker-zabbix-centos"
BOX_URI =  ENV['BOX_URI']  || "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box"
FORWARD_DOCKER_PORTS = ENV['FORWARD_DOCKER_PORTS']

# Providers were added on Vagrant >= 1.1.0
Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]

    config.vm.box = BOX_NAME
    config.vm.box_url = BOX_URI
    config.vm.boot_timeout = 120
    config.ssh.forward_agent = true
    config.vm.network "private_network", type: "dhcp"
    config.vm.synced_folder ".", "/docker/docker-zabbix"

    # Provision docker and new kernel if deployment was not done.
    # It is assumed Vagrant can successfully launch the provider instance.

     if Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/default/*/id").empty?

         script = <<-eos
            # Install EPEL repo.
            wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
            wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
            rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
            yum makecache
            # Add docker-io packages.
            yum -y install docker-io
            yum -y update docker-io
            # Add
            service docker start
            chkconfig docker on

         eos
         # Add guest additions if local vbox VM. As virtualbox is the default provider,
         # it is assumed it won't be explicitly stated.
         if ENV["VAGRANT_DEFAULT_PROVIDER"].nil? && ARGV.none? { |arg| arg.downcase.start_with?("--provider") }
             script << <<-eos
                 echo 'Downloading VBox Guest Additions...'
                 wget -q http://dlc.sun.com.edgesuite.net/virtualbox/4.3.0/VBoxGuestAdditions_4.3.0.iso
                 # Prepare the VM to add guest additions after reboot
                 echo -e 'mount -o loop,ro /home/vagrant/VBoxGuestAdditions_4.3.0.iso /mnt\n
                 echo yes | /mnt/VBoxLinuxAdditions.run\numount /mnt\n
                 rm /root/guest_additions.sh; ' > /root/guest_additions.sh
                 chmod 700 /root/guest_additions.sh
                 sed -i -E 's#^exit 0#[ -x /root/guest_additions.sh ] \\&\\& /root/guest_additions.sh#' /etc/rc.local
                 echo 'Installation of VBox Guest Additions is proceeding in the background.'
                 echo '\"vagrant reload\" can be used in about 2 minutes to activate the new guest additions.'

             eos
         end
         # Activate new kernel
         script << "shutdown -r +1"

         config.vm.provision :shell, :inline => script
     end
  end
end

if !FORWARD_DOCKER_PORTS.nil?
  Vagrant.configure("2") do |config|
    (49000..49900).each do |port|
      config.vm.network :forwarded_port, :host => port, :guest => port
    end
  end
end
