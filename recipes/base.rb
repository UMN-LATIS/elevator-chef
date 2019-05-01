#
# Cookbook Name:: elevator
# Recipe:: base
#
# Copyright (C) 2015 Colin McFadden
#
# All rights reserved - Do Not Redistribute
#

ENV['GIT_SSL_NO_VERIFY'] = "1"

node.override['apt']['compile_time_update'] = true

chef_client_updater 'Install latest Chef 14.x' do
  version '14'
  only_if { node['elevator']['upgrade_chef'] == true }
end


#this seems hacky, but the apt include actually fails without it
execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
  action :nothing
end

include_recipe "apt"

#include_recipe "apt-upgrade-once"

# Set the node attributes for ntp
node.default['ntp']['servers'] = ['pool.ntp.org'];
# include the recipe
include_recipe 'ntp'



execute 'mkfs' do
  command "mkfs -t ext4 /dev/xvdg"
  # only if it's not mounted already
  not_if "grep -qs #{node['elevator']['config']['scratchspace']} /proc/mounts"
  only_if "ls /dev | grep -qs xvdg"
end

directory node['elevator']['config']['scratchspace'] do
   mode '0777'
  not_if "grep -qs #{node['elevator']['config']['scratchspace']} /proc/mounts"
 end


# now we can enable and mount it and we're done!
mount node['elevator']['config']['scratchspace'] do
  device '/dev/xvdg'
  fstype 'ext4'
  action [:enable, :mount]
  not_if "grep -qs #{node['elevator']['config']['scratchspace']} /proc/mounts"
  only_if "ls /dev | grep -qs xvdg"
end


include_recipe 'chef-client::config'
include_recipe 'chef-client::service'

