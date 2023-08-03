

#!/bin/bash



# Set the IP address of the Redis master node

REDIS_MASTER=${MASTER_IP_ADDRESS}



# Check if the Redis master node is responding

if ping -c 1 $REDIS_MASTER > /dev/null; then

    echo "Redis master node is up"

else

    # If the node is down, bring it back up

    echo "Redis master node is down, attempting to bring it back up..."

    sudo service redis-server start



    # Wait for Redis to start up

    sleep 10s



    # Check if Redis is running

    if systemctl is-active --quiet redis-server; then

        # If Redis is running, promote the node to become the new master

        redis-cli -h $REDIS_MASTER slaveof no one

        echo "Redis master node has been restarted and promoted"

    else

        # If Redis is not running, print an error message

        echo "Failed to start Redis master node"

    fi

fi