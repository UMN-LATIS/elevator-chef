# configure the code


template "#{node['elevator']['install_directory']}/application/config/config.php" do
	source "config.php.erb"
end

databag = data_bag_item("elevator", "dbuser")

template "#{node['elevator']['install_directory']}/application/config/database.php" do
	source "database.php.erb"
	variables ({
		:dbuser => databag['username'],
		:dbpassword => databag['password']
	})
end

template "#{node['elevator']['install_directory']}/.htaccess" do
	source "htaccess.erb"
	owner node['elevator']['user']
	group node['elevator']['group']
	mode "0664"
end
