
# ### Set up database schema
# execute "update_db_schema" do
# 	cwd node['elevator']['install_directory']
# 	command "php doctrine.php orm:schema-tool:update --force"
# 	action :nothing
# 	subscribes :run, "template[#{node['elevator']['install_directory']}/application/config/database.php]"
# end

# ### Set up MongoDB
# execute "update_mongo_schema" do
# 	cwd node['elevator']['install_directory']
# 	command "mongo #{node['elevator']['mongodb']['hostname']}:#{node['elevator']['mongodb']['port']}/#{node['elevator']['mongodb']['collection']} documentation/mongoSetup.js"
# 	action :nothing
# 	subscribes :run, "template[#{node['elevator']['install_directory']}/application/config/database.php]"
# end
