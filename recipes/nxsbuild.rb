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

unless FileTest.exists?('/tmp/nexus/nexus-4.0.1/')
	package "qt4-dev-tools"

	directory "/tmp/nexus" do
		mode "0777" # tempfile directory
		action :create
	end
	tar_extract 'https://github.com/UMN-LATIS/nexus/archive/4.0.1.tar.gz' do
		target_dir '/tmp/nexus' # Will be created if missing
		action :extract
	end

	bash "buildnxs" do
		code "cd /tmp/nexus/nexus-4.0.1/nxsbuild; qmake nxsbuild.pro; make"
	end

	bash "install-nxs" do
    	code "mv /tmp/nexus/nexus-4.0.1/bin/nxsbuild #{node['elevator']['config']['binaries']['nxsbuild_dir']}"
  	end

end