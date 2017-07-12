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

execute 'imagemagick_builddep' do
  command 'apt-get -y build-dep imagemagick'
end

package "libgs-dev"
package "imagemagick"
package "pkg-config"
# package "libmagickwand-dev"
package "xz-utils"

include_recipe "tar"

remote_file "/tmp/ImageMagick-#{node['elevator']['imagemagick']['version']}.tar.xz" do
  source node['elevator']['imagemagick']['path']
  notifies :run, "bash[install_imagemagick]", :immediately
end

bash "install_imagemagick" do
  not_if "/usr/local/bin/identify --version | grep -q '#{node['elevator']['imagemagick']['version']}'"
  user "root"
  cwd "/tmp"
  code <<-EOH
    tar -xf ImageMagick-#{node['elevator']['imagemagick']['version']}.tar.xz
    (cd ImageMagick-#{node['elevator']['imagemagick']['version']}/ && ./configure  --with-gslib=yes && make && make install)
    sudo ldconfig /usr/local/lib/
  EOH
  action :nothing
end

php_pear 'imagick' do
  action :install
  if File.exist?("/etc/init.d/apache2")
    notifies :restart, resources(:service => "apache2")
  end
  notifies :reload, "bluepill_service[elevatorTranscode]", :delayed
end

template '/usr/local/etc/ImageMagick-7/policy.xml' do
  source 'imagemagick.erb'
end

