include_recipe "apt"
include_recipe "git"
#include_recipe "oh-my-zsh"
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"
include_recipe "mysql::server"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "apache2::mod_php5"
include_recipe "composer"
#include_recipe "drush"

# Install packages
%w{ debconf vim screen tmux mc subversion curl make g++ libsqlite3-dev graphviz libxml2-utils lynx links}.each do |a_package|
  package a_package
end

# Install ruby gems
%w{ rake mailcatcher }.each do |a_gem|
  gem_package a_gem
end

# Generate selfsigned ssl
execute "make-ssl-cert" do
  command "make-ssl-cert generate-default-snakeoil --force-overwrite"
  ignore_failure true
  action :nothing
end

# Initialize sites data bag
#sites = []
#begin
#  sites = data_bag("sites")
#rescue
#  puts "Sites data bag is empty"
#end

# Configure sites
#sites.each do |name|
#  site = data_bag_item("sites", name)
#
#  # Add site to apache config
#  web_app site["host"] do
#    template "sites.conf.erb"
#    server_name site["host"]
#    server_aliases site["aliases"]
#    docroot site["docroot"]? site["docroot"]: "/var/www/#{site["host"]}"
#  end  
#
#   # Add site info in /etc/hosts
#   bash "hosts" do
#     code "echo 127.0.0.1 #{site["host"]} #{site["aliases"].join(' ')} >> /etc/hosts"
#   end
#end

# Disable default site
apache_site "default" do
  enable true  
end

# Install phpmyadmin
cookbook_file "/tmp/phpmyadmin.deb.conf" do
  source "phpmyadmin.deb.conf"
end
bash "debconf_for_phpmyadmin" do
  code "debconf-set-selections /tmp/phpmyadmin.deb.conf"
end
package "phpmyadmin"

# Install Xdebug
php_pear "xdebug" do
  action :install
end
template "#{node['php']['ext_conf_dir']}/xdebug.ini" do
  source "xdebug.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, resources("service[apache2]"), :delayed
end

# Install Webgrind
git "/var/www/webgrind" do
  repository 'git://github.com/jokkedk/webgrind.git'
  reference "master"
  action :sync
end
template "#{node[:apache][:dir]}/conf.d/webgrind.conf" do
  source "webgrind.conf.erb"
  owner "root"
  group "root"
  mode 0644
  action :create
  notifies :restart, resources("service[apache2]"), :delayed
end
template "/var/www/webgrind/config.php" do
  source "webgrind.config.php.erb"
  owner "root"
  group "root"
  mode 0644
  action :create
end

# Install php-curl
package "php5-curl" do
  action :install
end

#install pdftk (merge pdf)
#bash "pdftk-install" do
#  code "sudo apt-get install pdftk"
#end

# Get eth1 ip
eth1_ip = node[:network][:interfaces][:eth1][:addresses].select{|key,val| val[:family] == 'inet'}.flatten[0]

# Setup MailCatcher
bash "mailcatcher" do
  code "mailcatcher --http-ip #{eth1_ip} --smtp-port 25"
  not_if "ps ax | grep -v grep | grep mailcatcher";
end
template "#{node['php']['ext_conf_dir']}/mailcatcher.ini" do
  source "mailcatcher.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  action :create
  notifies :restart, resources("service[apache2]"), :delayed
end

# Fix deprecated php comments style in ini files
bash "deploy" do
  code "sudo perl -pi -e 's/(\s*)#/$1;/' /etc/php5/cli/conf.d/*ini"
  notifies :restart, resources("service[apache2]"), :delayed
end

# Upgrade PEAR
execute "sudo pear upgrade PEAR ; sudo pear config-set auto_discover 1; sudo pear -V > /tmp/pear/cache/version;" do
  not_if "cat /tmp/pear/cache/version | grep -i 'pear'"
end


# Install Phing
channel = "pear.phing.info"
execute "pear channel-discover #{channel}" do
  not_if "pear list-channels | grep #{channel}"
end

execute "pear install phing/phing" do
  not_if "pear list -c phing | grep '^phing '"
end


# Install PHPQA Tools
include_recipe "php"

channel = "pear.phing.info"
execute "pear channel-discover #{channel}" do
  not_if "pear list-channels | grep #{channel}"
end

execute "pear install pear.phpqatools.org/phpqatools" do
  not_if "pear list -c phpunit | grep -i '^PHPUnit '"
end
