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

package "libimage-exiftool-perl"

package "libgs-dev"
# package "imagemagick"
package "pkg-config"
# package "libmagickwand-dev"
package "xz-utils"

include_recipe "tar"

execute 'imagemagick_builddep' do
  command 'apt-get -y build-dep imagemagick'
end

## built with checkinstall

cookbook_file '/tmp/imagemagick-7.0.6_1-1_amd64.deb' do
  source 'imagemagick-7.0.6_1-1_amd64.deb'
  action :create
end

dpkg_package "install_imagick" do
  source "/tmp/imagemagick-7.0.6_1-1_amd64.deb"
  action :install
  notifies :run, "bash[imagick_pecl]", :immediately
end


# not needed on AWS
# execute "hack-debs" do
#   command "sed -i -- 's/#deb-src/deb-src/g' /etc/apt/sources.list && sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list && apt-get update"
#   notifies :run, "execute[imagemagick_builddep]", :immediately
#   action :nothing
# end




bash "imagick_pecl" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    sudo ldconfig /usr/local/lib/
    echo "/usr/local/" | pecl install imagick
    echo "extension=imagick.so" > /etc/php/7.0/mods-available/imagick.ini
    phpenmod imagick
  EOH
  action :nothing
end

template '/usr/local/etc/ImageMagick-7/policy.xml' do
  source 'imagemagick.erb'
end

