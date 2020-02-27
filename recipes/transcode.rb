#
# Cookbook Name:: --test-kitchen
# Recipe:: default
#
# Copyright (C) 2015 Joshua Buysse
#
# All rights reserved - Do Not Redistribute
#

# this only is going to support Ubuntu 14.04

#include_recipe "#{cookbook_name}::transcode"
include_recipe "#{cookbook_name}::base"
include_recipe "#{cookbook_name}::users"
include_recipe "#{cookbook_name}::install_code"
include_recipe "#{cookbook_name}::configure_code"


docker_installation_package 'default' do
  version '18.09.4'
  action :create
  package_options %q|--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all'| # if Ubuntu for example
end

node[:elevator][:containers].each do |k,v|
  imageName = "umnelevator/#{k}"
  docker_image imageName do
    action :pull
    tag v[:version]
  end
  docker_container k.gsub(/\//, "_").concat((Time.now.to_f * 1000).to_i.to_s) do
    repo imageName
    tag v[:version]
    running_wait_time 60
    action :run
  end
  overrideCommand = false
  if v[:command].nil?
    commands = [k]
  else
    commands = v[:command]
    overrideCommand = true
  end
  
  commands.each do |command|
    template "/usr/local/bin/#{command}" do
      source "dockerCommand.erb"
      variables ({
        :dockerImage => k,
        :dockerVersion => v[:version],
        :dockerCommand => overrideCommand ? command : ""
      })
      mode 0777
    end
  end

  ruby_block "sleep for 10"
    action :nothing
	  block do
		  sleep 10
	  end
  end
end


execute 'prune old containers' do
  command 'docker container prune -f --filter until=55m'
end

execute 'prune old images' do
  command 'docker image prune -f --all'
end

include_recipe "bluepill"


template '/etc/bluepill/elevatorTranscode.pill' do
  source 'bluepill.transcode.erb'
end


cron 'clean_storage' do
  action :create
  minute '0'
  hour '1'
  weekday '*'
  user 'root'
  command %W{/usr/bin/php #{node['elevator']['install_directory']}/index.php beltdrive cleanupSource}.join(' ')
end

bluepill_service 'elevatorTranscode' do
  action [:enable, :load, :start]
end
