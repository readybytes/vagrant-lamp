# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  # Set box configuration
  config.vm.box = "precise64"
  config.vm.box_url = "http://10.0.0.91/intranet/downloads/vagrant/boxes/precise64.box"

  # Uncomment these lines to give the virtual machine more memory and "dual core cpu"
  config.vm.customize ["modifyvm", :id, "--memory", 1024]
  config.vm.customize ["modifyvm", :id, "--cpus", 1]

  # Forward MySql port on 33066, used for connecting admin-clients to localhost:33066
  config.vm.forward_port 3306, 33066
  config.vm.forward_port 80, 8080

  # Set share folder permissions to 777 so that apache can write files
  config.vm.share_folder("shared-code", "/var/www", 	    "/vobs/shared/code", 		:extra => 'dmode=777,fmode=666')
  config.vm.share_folder("shared-db",   "/var/lib/mysql",   "/vobs/shared/db",			:extra => 'dmode=777,fmode=666')
  config.vm.share_folder("cache-pear",  "/tmp/pear/cache",  "/vobs/shared/cache/pear/cache",	:extra => 'dmode=777,fmode=666')

  # Reuse Repos
  config.vm.share_folder("shared-repos",  "/vobs",  	    "/vobs/repo",			:extra => 'dmode=777,fmode=666')

  # enable it by executing this command
  # ln -s -T ~/Dropbox /vobs/shared/dropbox
  config.vm.share_folder("shared-dropbox",  "/home/vagrant/Dropbox",  "/vobs/shared/dropbox",	:extra => 'dmode=777,fmode=666')

  # Use Proxy to speedup 
  config.vm.provision :shell, :inline => 'echo \'Acquire::http::proxy "http://10.0.0.31:3142";\' > /etc/apt/apt.conf.d/01proxy'

  # Assign this VM to a host-only network IP, allowing you to access it via the IP.
  config.vm.network :hostonly, "33.33.33.10"

  # Enable provisioning with chef solo, specifying a cookbooks path (relative
  # to this Vagrantfile), and adding some recipes and/or roles.
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.data_bags_path = "data_bags"
    chef.add_recipe "vagrant_main"

    chef.json.merge!({
      "mysql" => {
        "server_root_password" => "password",
        "server_repl_password" => "password",
        "server_debian_password" => "password",
        "bind_address" => "0.0.0.0"
      },
      "oh_my_zsh" => {
        :users => [
          {
            :login => 'vagrant',
            :theme => 'blinks',
            :plugins => ['git', 'gem']
          }
        ]
      }
    })
  end
end
