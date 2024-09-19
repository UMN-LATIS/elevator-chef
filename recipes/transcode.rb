#
# Cookbook Name:: --test-kitchen
# Recipe:: default
#
# Copyright (C) 2015 Joshua Buysse
#
# All rights reserved - Do Not Redistribute
#


# we need to tweak the grub setup, reboot the machine, and then continue
# this is because ubuntu doesn't default to having swap enabled for cgroups
# making this change for 20.04 updates

cron_path = {"PATH" =>"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"}

cron 'run chef at boot' do
  action :create
  time :reboot
  user 'root'
  environment cron_path
  command '/opt/chef/embedded/bin/ruby /usr/bin/chef-client -c /etc/chef/client.rb -P /var/run/chef/client.pid'
end

execute 'update grub' do
  command "echo 'GRUB_CMDLINE_LINUX=\"cdgroup_enable=memory swapaccount=1\"' >> /etc/default/grub && update-grub"
  not_if { File.readlines("/etc/default/grub").grep(/cdgroup_enable/).any? }
  notifies :reboot_now, 'reboot[now]', :immediately
end

reboot 'now' do
  action :nothing
  reason 'Cannot continue Chef run without a reboot.'
  delay_mins 0
end


#include_recipe "#{cookbook_name}::transcode"
include_recipe "#{cookbook_name}::base"
include_recipe "#{cookbook_name}::users"
include_recipe "#{cookbook_name}::install_code"
include_recipe "#{cookbook_name}::configure_code"


docker_installation_package 'default' do
  version '19.03.12'
  action :create
  package_options %q| -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all'| # if Ubuntu for example
end

node[:elevator][:containers].each do |k,v|
  imageName = "#{node[:elevator][:container_repo]}/#{k}"
  docker_image imageName do
    action :pull
    tag v[:version]
  end

  overrideCommand = false
  if v[:command].nil?
    commands = [k]
  else
    commands = v[:command]
    overrideCommand = true
  end
  
  ruby_block 'set_first_run_state' do
    block do
      node.run_state['not_first_run'] = true
    end
    only_if { ::File.exist?("/usr/local/bin/#{commands.first}") }
  end

  docker_container k.gsub(/\//, "_").concat((Time.now.to_f * 1000).to_i.to_s) do
    repo imageName
    tag v[:version]
    running_wait_time 120
    action :run
    only_if { ::File.exist?("/usr/local/bin/#{commands.first}") }
  end

  commands.each do |command|
    template "/usr/local/bin/#{command}" do
      source "dockerCommand.erb"
      variables ({
        :dockerImage => imageName,
        :dockerVersion => v[:version],
        :dockerCommand => overrideCommand ? command : ""
      })
      mode 0777
    end
  end

end


execute 'prune old containers' do
  command 'docker container prune -f --filter until=55m'
  only_if {node.run_state.has_key? 'not_first_run'}
end

execute 'prune old images' do
  command 'docker image prune -f --all'
  only_if {node.run_state.has_key? 'not_first_run'}
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
  command %W{/usr/bin/php #{node['elevator']['install_directory']}/index.php beltdrive cleanupSource  > /dev/null 2>&1}.join(' ')
end


swap_file 'local_swap' do
  path            "/scratch/swap" # default value: 'name' unless specified
  persist         false # default value: false
  size            10000
  swappiness      60
  action          :create # defaults to :create if not specified
end

bluepill_service 'elevatorTranscode' do
  action [:enable, :load, :start]
end
