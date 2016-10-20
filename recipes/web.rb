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

include_recipe "#{cookbook_name}::install_code"


# Install apache web server
node.set['apache']['mpm'] = 'prefork'

include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_deflate"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_headers"
include_recipe "apache2::mod_php5"
include_recipe "cookbook-shibboleth::sp"

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

databag = data_bag_item("elevator", "ssl")

certPath = "/etc/apache2/ssl/elevator.crt"
keyPath =  "/etc/apache2/ssl/elevator.key"
intermediatePath =  "/etc/apache2/ssl/intermediate.crt"

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


include_recipe "#{cookbook_name}::configure_code"

include_recipe "#{cookbook_name}::configure_schemas"

include_recipe "bluepill"

template '/etc/bluepill/elevatorWeb.pill' do
  source 'bluepill.web.erb'
end

bluepill_service 'elevatorWeb' do
  action [:enable, :load, :start]
end