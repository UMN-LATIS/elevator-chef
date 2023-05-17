#
# Cookbook Name:: --test-kitchen
# Recipe:: default
#
# Copyright (C) 2015 Joshua Buysse
#
# All rights reserved - Do Not Redistribute
#

# this only is going to support Ubuntu 14.04

#include_recipe "#{cookbook_name}::messagequeue"
include_recipe "#{cookbook_name}::base"
include_recipe "#{cookbook_name}::users"

node.default['beanstalkd']['start_during_boot'] = true
node.default['beanstalkd']['opts'] = {
  "b" => "/var/lib/beanstalkd"
}
node.default['beanstalkd']['listen_addr'] = node['network']['ipaddress'] || "0.0.0.0"
node.default['beanstalkd']['listen_port'] = 11300

include_recipe "beanstalkd"
# workaround due to https://github.com/poise/poise-python/issues/140
node.default['poise-python']['options']['pip_version'] = '18.0'
include_recipe "poise-python"

python_package "boto"
python_package "beanstalkc"
python_package "pyyaml"

remote_file "/usr/local/bin/beanstalkd_cloudwatch" do
  source "https://raw.githubusercontent.com/erans/beanstalkdcloudwatch/master/beanstalkd_cloudwatch.py"
  mode 0775
  notifies :run, 'execute[change_keepalive]', :delayed
end

execute 'change_keepalive' do
  command 'echo 1200 > /proc/sys/net/ipv4/tcp_keepalive_time'
  action :nothing
end

databag = data_bag_item("elevator", "aws")


# TODO: check that pythong is realy installed and this script runs?

cron 'update_cloudwatch' do
  action :create
  minute '*'
  hour '*'
  weekday '*'
  user 'elevator'
  command %W{/usr/local/bin/beanstalkd_cloudwatch -k #{databag['aws_key']} -s #{databag['aws_secret']} -t transcoder -e current-jobs-urgent -n AutoScaling -m transcodeStatus-#{node.chef_environment}}.join(' ')
end

cron 'update_cloudwatch_reserved' do
  action :create
  minute '*'
  hour '*'
  weekday '*'
  user 'elevator'
  command %W{/usr/local/bin/beanstalkd_cloudwatch -k #{databag['aws_key']} -s #{databag['aws_secret']} -t transcoder -e current-jobs-reserved -n AutoScaling -m transcodeStatus-reserved-#{node.chef_environment}}.join(' ')
end


cron 'update_cloudwatch_processing' do
  action :create
  minute '*'
  hour '*'
  weekday '*'
  user 'elevator'
  command %W{/usr/local/bin/beanstalkd_cloudwatch -k #{databag['aws_key']} -s #{databag['aws_secret']} -t newUploads -e current-jobs-urgent -n AutoScaling -m processingStatus-#{node.chef_environment}}.join(' ')
end

cron 'update_cloudwatch_processing_reserved' do
  action :create
  minute '*'
  hour '*'
  weekday '*'
  user 'elevator'
  command %W{/usr/local/bin/beanstalkd_cloudwatch -k #{databag['aws_key']} -s #{databag['aws_secret']} -t newUploads -e current-jobs-reserved -n AutoScaling -m processingStatus-reserved-#{node.chef_environment}}.join(' ')
end
