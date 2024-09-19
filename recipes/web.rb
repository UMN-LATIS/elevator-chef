#
# Cookbook Name:: --test-kitchen
# Recipe:: default
#
# Copyright (C) 2015 Joshua Buysse
#
# All rights reserved - Do Not Redistribute
#

# this only is going to support Ubuntu 14.04

#include_recipe "#{cookbook_name}::web"

include_recipe "#{cookbook_name}::base"
include_recipe "#{cookbook_name}::users"



# Install apache web server
node.default['apache']['mpm'] = 'prefork'

include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_deflate"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_headers"
include_recipe "apache2::mod_php"
include_recipe "cookbook-shibboleth::sp"


template '/etc/shibboleth/shibboleth2.xml' do
  source node['elevator']['config']['shibboleth']['shibbolethPath'] + '/shibboleth2.xml.erb'
  only_if node['elevator']['config']['shibboleth']['enableShibboleth']
end

template '/etc/shibboleth/attribute-map.xml' do
  source node['elevator']['config']['shibboleth']['shibbolethPath'] + '/attribute-map.xml.erb'
  only_if node['elevator']['config']['shibboleth']['enableShibboleth']
end

template '/etc/shibboleth/attribute-policy.xml' do
  source node['elevator']['config']['shibboleth']['shibbolethPath'] + '/attribute-policy.xml.erb'
  only_if node['elevator']['config']['shibboleth']['enableShibboleth']
end

databag_shib = data_bag_item("elevator", "shibboleth")

certPath = "/etc/shibboleth/sp-cert.pem"
keyPath =  "/etc/shibboleth/sp-key.pem"

file certPath do
  content databag_shib[node.chef_environment]["certificate"]
  owner "_shibd"
  group "root"
  mode 0600
  only_if node['elevator']['config']['shibboleth']['enableShibboleth']
end

file keyPath do
  content databag_shib[node.chef_environment]["key"]
  owner "_shibd"
  group "root"
  mode 0600
  only_if node['elevator']['config']['shibboleth']['enableShibboleth']
  notifies :restart, "service[shibd]", :immediately
end

service 'shibd' do
  action :nothing
end


# apache recipe currently misses this file
file "/etc/apache2/mods-available/php7.conf" do
  owner 'root'
  group 'root'
  mode 0755
  content lazy { ::File.open("/etc/apache2/mods-available/php.conf").read }
  action :create
  notifies :run, "execute[toggle_php7_mod]", :immediately
end

execute 'toggle_php7_mod' do
  command 'a2dismod php7; a2enmod php7'
  action :nothing
end


file "/etc/php/7.4/apache2/conf.d/50-tune-opcache.ini" do
    owner "root"
    group "root"
    mode "0755"
    action :create
    content "opcache.max_accelerated_files=12000\nopcache.memory_consumption=256\nopcache.interned_strings_buffer=16\nopcache.fast_shutdown=1\n"
    notifies :restart, resources(:service => "apache2")
end



include_recipe "#{cookbook_name}::install_code"

package "sendmail"

# disable the default site
apache_site "000-default" do
  enable false
end

service "apache2" do
  ignore_failure true
  action :start
end

web_app "elevator" do
  source "web_app.erb"
  cookbook "elevator"
  use_ssl false
  vhost_address '*'
  server_name node['elevator']['config']['web_hostname']
  docroot node['elevator']['install_directory']
  directory_index ["index.php", "index.html"]
  allow_override "all"
  log_level 'info'
  enable true
end



certPath = "/etc/apache2/ssl/elevator.crt"
keyPath =  "/etc/apache2/ssl/elevator.key"


if node['elevator']["letsencrypt"]["enable_letsencrypt"] == false
  intermediatePath =  "/etc/apache2/ssl/intermediate.crt"
  databag = data_bag_item("elevator", "ssl")

  file certPath do
    content databag[node.chef_environment]["certificate"]
    owner "root"
    group "root"
    mode 0600
  end

  file keyPath do
    content databag[node.chef_environment]["key"]
    owner "root"
    group "root"
    mode 0600
  end

  file intermediatePath do
    content databag[node.chef_environment]["intermediate"]
    owner "root"
    group "root"
    mode 0600
  end
end


web_app "elevator_ssl" do
  source "web_app.erb"
  cookbook "elevator"
  use_ssl true
  vhost_address '*'
  server_name node['elevator']['config']['web_hostname']
  docroot node['elevator']['install_directory']
  directory_index ["index.php", "index.html"]
  allow_override "all"
  log_level 'info'
  ssl_intermediate_cert intermediatePath
  ssl_cert certPath
  ssl_key keyPath
  enable true
end


if node['elevator']["letsencrypt"]["enable_letsencrypt"] == true

  include_recipe 'acme'
  node.override['acme']['contact'] = [node['elevator']["letsencrypt"]["contact"]]
  # node.override['acme']['endpoint'] = 'https://acme-v02.api.letsencrypt.org'
  node.override['acme']['dir'] = 'https://acme-v02.api.letsencrypt.org/directory'
  site = node['elevator']["letsencrypt"]["hostname"]
  
  # generate a self-signed cert and boot apache
  acme_selfsigned "#{site}" do
    crt     certPath
    key     keyPath
    chain    intermediatePath
    owner   "root"
    group   "root"
    notifies :restart, "service[apache2]", :immediate
  end


  acme_certificate "#{site}" do
    crt               certPath
    key               keyPath
    chain             intermediatePath
    wwwroot           "/opt/elevator/"
    notifies :restart, "service[apache2]"
    # alt_names sans
  end
end


cron 'update_date_holds' do
  action :create
  minute '0'
  hour '2'
  weekday '*'
  user 'root'
  command %W{/usr/bin/php #{node['elevator']['install_directory']}/index.php admin updateDateHolds  > /dev/null 2>&1}.join(' ')
end



include_recipe "#{cookbook_name}::configure_code"

include_recipe "#{cookbook_name}::configure_schemas"

include_recipe "bluepill"

template '/etc/bluepill/elevatorWeb.pill' do
  source 'bluepill.web.erb'
end

bluepill_service 'elevatorWeb' do
  action [:enable, :load, :start]
end


# TODO:  host limits connections per IP
#/sbin/iptables -A INPUT -p tcp --syn --dport 80 -m connlimit --connlimit-above 60 -j REJECT --reject-with tcp-reset
#/sbin/iptables -A INPUT -p tcp --syn --dport 443 -m connlimit --connlimit-above 60 -j REJECT --reject-with tcp-reset

# iptables_rule 'Rate limit' do
#   table :filter
#   chain :INPUT
#   protocol :tcp
#   match 'socket'
#   ip_version :ipv4
#   jump 'REJECT'
# end