# The scripts in this file are only meant to be ran in the SRG clusters

1. Install (redis)[https://redis.io/docs/latest/operate/oss_and_stack/install/archive/install-redis/install-redis-from-source/] and ensure that it is in the same directory as the top level redis folder

# How to run
1. Use ssh key forwarding 
2. Provide: {absolute path of go code} {absolute path where you want your output} \
(Example) ./run.sh ~/moveri/redis/redis_client ~/redis_output


