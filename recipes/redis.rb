
package "redis-server"

include_recipe "L7-redis"

L7_redis_pool 'elevator_cache'  do
	bind '0.0.0.0'
end
