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

# include_recipe "zipfile"

unless FileTest.exists?(node['elevator']['config']['binaries']['rtibuild_dir'])
	package "qt4-dev-tools"

	directory "/tmp/rti" do
		mode "0777" # tempfile directory
		action :create
	end
	
	remote_file "/tmp/rti.zip" do
  		source "http://vcg.isti.cnr.it/~palma/webRTIViewer.zip"
  		mode 0644
	end

	zipfile '/tmp/rti.zip' do
		into '/tmp/rti' # Will be created if missing
		action :extract
	end

	bash "buildrti" do
		code "cd /tmp/rti/webRTIViewer/webGLRTIMaker-src; qmake webGLRtiMaker.pro; make"
	end

	bash "install-rti" do
    	code "mv /tmp/rti/webRTIViewer/webGLRTIMaker-src/webGLRtiMaker #{node['elevator']['config']['binaries']['rtibuild_dir']}"
  	end

end