#
# Cookbook Name:: elevator
# Recipe:: nxsbuild
#
# This is a mess and should be redone
#
# Copyright (C) 2015 Colin McFadden
#
# All rights reserved - Do Not Redistribute
#

include_recipe "tar"

unless FileTest.exists?('/tmp/nexus/nexus_update-4.1.6/')
	package "qt5-default" 
	package "libglew-dev"

	directory "/tmp/nexus" do
		mode "0777" # tempfile directory
		action :create
	end
	tar_extract 'https://github.com/UMN-LATIS/nexus_update/archive/4.1.6.tar.gz' do
		target_dir '/tmp/nexus' # Will be created if missing
		action :extract
	end

	tar_extract 'https://github.com/UMN-LATIS/vcglib/archive/elevator.tar.gz' do
		target_dir '/tmp/nexus' # Will be created if missing
		action :extract
	end



	bash "buildnxs" do
		code "cd /tmp/nexus; mv vcglib-elevator vcglib; cd /tmp/nexus/nexus_update-4.1.6/src/nxsbuild; qmake nxsbuild.pro; make"
	end

	bash "install-nxs" do
    	code "mv /tmp/nexus/nexus_update-4.1.6/bin/nxsbuild #{node['elevator']['config']['binaries']['nxsbuild_dir']}"
  	end

  	bash "buildnxsedit" do
		code "cd /tmp/nexus/nexus_update-4.1.6/src/nxsedit; qmake nxsedit.pro; make"
	end

	bash "install-nxsedit" do
    	code "mv /tmp/nexus/nexus_update-4.1.6/bin/nxsedit #{node['elevator']['config']['binaries']['nxsedit_dir']}"
  	end

end