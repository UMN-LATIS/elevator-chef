#
# Cookbook Name:: --test-kitchen
# Recipe:: default
#
# Copyright (C) 2015 Joshua Buysse
#
# All rights reserved - Do Not Redistribute
#

# this only is going to support Ubuntu 14.04

# this installs everything on one node

# this is horrible.
# new cert on github.umn.edu blows up composer
# need to install full cacert bundles as part of install
ENV['GIT_SSL_NO_VERIFY'] = "1"

include_recipe "#{cookbook_name}::base"

# include_recipe "#{cookbook_name}::transcode"
### database is taken care of by RDS normally.
include_recipe "#{cookbook_name}::messagequeue"
include_recipe "#{cookbook_name}::web"
include_recipe "#{cookbook_name}::elasticsearch"
include_recipe "#{cookbook_name}::transcode"

