include_recipe "#{cookbook_name}::git_setup"



# install PHP
include_recipe "php"
package "php7.0-pgsql"
package "php7.0-curl"
package "php7.0-ldap"
package "php-apcu"
package "php-mongodb"
# package "php-imagick"
package "php7.0-dev"
package "php-redis"
package "zip"
package "unzip"
package "php7.0-zip"

package "git-flow"

# why do we uninstall this?  Not sure.  Maybe has to do with redis?  Would have been nice if there were comments.
package "php-igbinary" do
	action :remove
end

node.override['php']['directives'] =  { 'session.gc_maxlifetime' => 43200 }

# Before running composer, let's cache some well-known remote ssh keys.  Saves
# against some ways it'll break (wanting to be interactive).
ssh_known_hosts_entry 'github.com'
ssh_known_hosts_entry 'github.umn.edu'

# set up the web application, which uses composer for dependency management
include_recipe "composer"
include_recipe "composer::self_update"

include_recipe "#{cookbook_name}::users"

directory node['elevator']['install_directory'] do
	user node['elevator']['user']
	group node['elevator']['group']
	mode "02775"
end

# remote_file "/etc/ssl/certs/ca-certificates.crt" do
#   source "http://s3.amazonaws.com/elevator-assets/ca-certificates.crt"
#   mode 0755
# end



git node['elevator']['install_directory'] do
	repository node['elevator']['git']['repository']
	revision node['elevator']['git']['ref']
	user node['elevator']['user']
	group node['elevator']['group']
	notifies :install, "composer_project[#{node['elevator']['install_directory']}]"
	# notifies :run, "execute[update_application_models]", :delayed
	if node.recipes.include?('elevator::web')
		notifies :reload, "bluepill_service[elevatorWeb]", :delayed
	end
	if node.recipes.include?('elevator::transcode')
		notifies :reload, "bluepill_service[elevatorTranscode]", :delayed
	end
	action :sync
end


execute "add_group_write_to_install_dir" do
  command "chmod -R g+w #{node['elevator']['install_directory']}"
end

# Doctrine needs this as a temporary directory.
directory "#{node['elevator']['install_directory']}/application/models/Proxies" do
	mode "0777" # tempfile directory
	action :create
end

composer_project node['elevator']['install_directory'] do
	dev false
 	quiet false
 	notifies :create, "template[#{node['elevator']['install_directory']}/vendor/doctrine/dbal/postgresPatch]", :delayed
	action :nothing
end


# TODO: this is a hack while we wait for doctrine 2.6 to ship

template "#{node['elevator']['install_directory']}/vendor/doctrine/dbal/postgresPatch" do
	source "doctrinePatch.erb"
	action :nothing
	notifies :run, "execute[composer_doctrine_hack]", :delayed
end

execute "composer_doctrine_hack" do
	cwd "#{node['elevator']['install_directory']}/vendor/doctrine/dbal"
	command "patch -p1 < postgresPatch"
	action :nothing
	not_if { ::File.exist? "#{node['elevator']['install_directory']}/vendor/doctrine/dbal/lib/Doctrine/DBAL/Platforms/PostgreSQL94Platform.php" }
end


# More dependencies, not covered by packaged modules
# php_pear "mongo" do
# 	action :install
# end

# this is a workaround for issues with the PHP cookbook
# on 14.04
# execute "enable_mongo_php" do
# 	command "php5enmod mongo"
# 	# should have a guard
# end

# execute "update_application_models" do
# 	cwd node['elevator']['install_directory']
# 	command "php doctrine.php orm:generate-entities application/models"
# 	notifies :run, "execute[update_application_proxies]", :immediately
# 	action :nothing
# end

# execute "update_application_proxies" do
# 	cwd node['elevator']['install_directory']
# 	command "php doctrine.php orm:generate-proxies application/models/Proxies"
# 	notifies :run, "execute[update_proxies_perms]", :immediately
# 	action :nothing
# end

# execute "update_proxies_perms" do
# 	cwd node['elevator']['install_directory']
# 	command "chmod 777 application/models/Proxies"
# 	action :nothing
# end