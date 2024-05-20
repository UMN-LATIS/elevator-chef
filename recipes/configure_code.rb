# configure the code

ldap = data_bag_item("elevator", "ldap")

template "#{node['elevator']['install_directory']}/application/config/config.php" do
	source "config.php.erb"
	variables ({
		:ldapuser => ldap[node.chef_environment]['ldapusername'],
		:ldappass => ldap[node.chef_environment]['ldappassword']
	})
end


email = data_bag_item("elevator", "emailuser")

template "#{node['elevator']['install_directory']}/application/config/email.php" do
	source "email.php.erb"
	variables ({
		:emailuser => email[node.chef_environment]['username'],
		:emailpass => email[node.chef_environment]['password']
	})
end

databag = data_bag_item("elevator", "dbuser")

template "#{node['elevator']['install_directory']}/application/config/database.php" do
	source "database.php.erb"
	variables ({
		:dbuser => databag[node.chef_environment]['username'],
		:dbpassword => databag[node.chef_environment]['password']
	})
end

template "#{node['elevator']['install_directory']}/.htaccess" do
	source "htaccess.erb"
	owner node['elevator']['user']
	group node['elevator']['group']
	mode "0664"
end


template "#{node['elevator']['install_directory']}/.env" do
	source "env.erb"
	variables ({
		:ldapuser => ldap[node.chef_environment]['ldapusername'],
		:ldappass => ldap[node.chef_environment]['ldappassword'],
		:dbuser => databag[node.chef_environment]['username'],
		:dbpassword => databag[node.chef_environment]['password'],
		:emailuser => email[node.chef_environment]['username'],
		:emailpass => email[node.chef_environment]['password']
	})
end