

#!/bin/bash



# Set the Redis node that will be promoted to master

REDIS_NODE=${NODE_NAME}



# Promote the Redis node to master

redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} cluster failover force