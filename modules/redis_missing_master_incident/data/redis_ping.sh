bash

#!/bin/bash



# Set the IP address of the Redis cluster master node

REDIS_MASTER=${IP_ADDRESS_OF_REDIS_MASTER_NODE}



# Ping the Redis master node to check if it is reachable

ping -c 1 $REDIS_MASTER



# Check if the Redis master node is responding to Redis requests

redis-cli -h $REDIS_MASTER ping