include_recipe "#{cookbook_name}::base"
include_recipe "#{cookbook_name}::install_code"
include_recipe "#{cookbook_name}::configure_code"

node.set['java']['install_flavor'] = 'oracle'
node.set['java']['jdk_version'] = '8'
node.set['java']['oracle']['accept_oracle_download_terms'] = true



include_recipe "java"

# take the elasticsearch version from the wrapper cookbook.
node.set['elasticsearch']['version'] = node['elevator']['elasticsearch']['version']

include_recipe "elasticsearch"
#include_recipe "elasticsearch::aws"

elasticsearch_configure 'elasticsearch' do
    allocated_memory '1975m'
    configuration ({
      'http.cors.enabled' => true,
      'http.cors.allow-origin' => '*',
      'network.host' => '0.0.0.0'
    })
end

# unless FileTest.exists?("/usr/local/elasticsearch/plugins/head/")
# 	bash "elasticHead" do
# 		code "cd /usr/local/elasticsearch; ./bin/plugin -install mobz/elasticsearch-head"
# 	end
# end

# service 'elasticsearch' do
#   action [:enable, :start]
# end

#TODO:
Chef::Log.warn("Elasticsearch instance setup (collection creation, etc.) not complete.")

### Set up Elasticsearch:
elasticsearch_uri = "http://localhost:#{node['elevator']['elasticsearch']['port']}/elevator"

### this is an absurd steaming pile, but seems to be needed to work around other issues.
ruby_block "delay_action_es_start" do
	action :nothing
	block do
		true
	end
	subscribes :run, "service[elasticsearch]", :delayed
end

### These don't seem to work.  Here's the manual code just in case
###curl -XPUT 'http://localhost:9200/elevator/'
###curl -XPUT http://localhost:9200/elevator/asset/_mapping -d '{
###    "asset" : {
###        "properties" : {
###            "locationCache" : {"type" : "geo_point"},
###            "fileSearchData": { "type": "string", "boost": 0.8 }
###        }
###    }
###}'


http_request "es_create_collection" do
	url "#{elasticsearch_uri}/"
	action :nothing
	subscribes :put, "ruby_block[delay_action_es_start]", :delayed
end

http_request "es_configure_collection" do
	url "#{elasticsearch_uri}/asset/_mapping"
	message ( { :asset => {
					:date_detection => 0,
					:properties => {
						:locationCache => { :type => "geo_point" }
					}
				}
			}.to_json )
	action :nothing
	subscribes :put, "http_request[es_create_collection]", :immediately
end

