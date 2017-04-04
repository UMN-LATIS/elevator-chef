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
#include_recipe "#{cookbook_name}::imagemagick"

include_recipe "chef-msttcorefonts"

# We need a PPA for some of this software
apt_repository "mc3man_trusty-media" do
	uri "ppa:mc3man/trusty-media"
	distribution node['lsb']['codename']
end

# We need a PPA for some of this software
apt_repository "dhor_myway" do
	uri "ppa:dhor/myway"
	distribution node['lsb']['codename']
end

# We need a PPA for some of this software
apt_repository "coolwanglu_pdf2htmlex" do
  uri "ppa:coolwanglu/pdf2htmlex"
  distribution node['lsb']['codename']
end


####
# OpenJPEG on Ubuntu 14.04 is broken - doesn't support mixed res color components which breaks vips.
# Force install the version of saucy.
####

remote_file "/tmp/old_openjpeg.deb" do
  source "http://launchpadlibrarian.net/147357170/libopenjpeg2_1.3%2Bdfsg-4.6ubuntu2_amd64.deb"
  mode 0644
end

dpkg_package "old_openjpeg" do
  source "/tmp/old_openjpeg.deb"
  action :install
end

execute 'hold_old_openjpeg' do
  command '/usr/bin/apt-mark hold libopenjpeg2'
end


###
# libtiff4 is missing on ubuntu 14.04
# and is required for libpoppler / poppler, which provides pdfimages
###

remote_file "/tmp/libtiff4.deb" do
  source "http://old-releases.ubuntu.com/ubuntu/pool/universe/t/tiff3/libtiff4_3.9.7-2ubuntu1_amd64.deb"
  mode 0644
end

dpkg_package "libtiff4" do
  source "/tmp/libtiff4.deb"
  action :install
end

package "imagemagick"
package "ffmpeg"  # TODO: might not include qtfaststart
package "yamdi"
package "blender"
package "meshlab" # might need to come from a different PPA
package "gifsicle"
package "gnuplot"
package "libvips42"
package "Xvfb"
package "libvips-tools"
package "openslide-tools"
package "libreoffice"
package "libreoffice-script-provider-python"
package "unoconv"
package "ghostscript"
package "libpoppler46"
package "poppler-utils"
package "tesseract-ocr"

node.default["r"]["install_method"] = "package"
node.default["r"]["cran_mirror"] = "http://cran.rstudio.com/"
include_recipe "r"

# r_package "Rcpp"
r_package "ggplot2"


service "xvfb" do
  supports :restart => true, :start => true, :stop => true, :reload => true
  action :nothing
end


template "xvfb" do
  path "/etc/init.d/xvfb"
  source "xvfb.erb"
  owner "root"
  group "root"
  mode "0755"
  notifies :enable, "service[xvfb]"
  notifies :start, "service[xvfb]"
end

include_recipe "elevator::nxsbuild"
include_recipe "elevator::rtibuild"

include_recipe "bluepill"


git '/usr/local/bin/spatial-media' do
  repository 'https://github.com/google/spatial-media.git'
  revision 'master'
  action :sync
end


include_recipe "python"
python_pip "pillow"
python_pip "pypdfocr"

git '/usr/local/bin/imagepacker' do
  repository 'https://github.com/UMN-LATIS/imagepacker.git'
  revision 'master'
  action :sync
end


template '/etc/bluepill/elevatorTranscode.pill' do
  source 'bluepill.transcode.erb'
end

template '/etc/ImageMagick/policy.xml' do
  source 'imagemagick.erb'
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
