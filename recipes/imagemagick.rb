#
# Cookbook Name:: elevator
# Recipe:: imagemagick
#
# This is a mess and should be redone
#
# Copyright (C) 2017 Colin McFadden
#
# All rights reserved - Do Not Redistribute
#

package "imagemagick"

include_recipe "tar"

remote_file "/tmp/ImageMagick-#{node['elevator']['imagemagick']['version']}.tar.gz" do
  source node['elevator']['imagemagick']['path']
  notifies :run, "bash[install_imagemagick]", :immediately
end

bash "install_imagemagick" do
  not_if "/usr/local/bin/identify --version | grep -q '#{node['elevator']['imagemagick']['version']}'"
  user "root"
  cwd "/tmp"
  code <<-EOH
    tar -zxf ImageMagick-#{node['elevator']['imagemagick']['version']}.tar.gz
    (cd ImageMagick-#{node['elevator']['imagemagick']['version']}/ && ./configure && make && make install)
    sudo ldconfig /usr/local/lib/
    echo "/usr/local/" | pecl install imagick
  EOH
  notifies :restart, resources(:service => "apache2")
  notifies :reload, "bluepill_service[elevatorTranscode]", :delayed
  action :nothing
end

