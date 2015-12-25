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

node.set['beanstalkd']['start_during_boot'] = true
node.set['beanstalkd']['opts'] = {
	"l" => node['network']['ipaddress'] || "0.0.0.0",
	"b" => "/var/lib/beanstalkd"
}

include_recipe "beanstalkd"
include_recipe "python"

python_pip "boto"
python_pip "beanstalkc"

remote_file "/usr/local/bin/beanstalkd_cloudwatch" do
  source "https://raw.githubusercontent.com/erans/beanstalkdcloudwatch/master/beanstalkd_cloudwatch.py"
  mode 0775
end

databag = data_bag_item("elevator", "aws")


cron 'update_cloudwatch' do
  action :create
  minute '*'
  hour '*'
  weekday '*'
  user 'elevator'
  command %W{/usr/local/bin/beanstalkd_cloudwatch -k #{databag['aws_key']} -s #{databag['aws_secret']} -t transcoder -e current-jobs-urgent -n AutoScaling -m transcodeStatus-#{node.chef_environment}}.join(' ')
end