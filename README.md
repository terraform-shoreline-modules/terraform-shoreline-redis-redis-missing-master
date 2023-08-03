
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Redis missing master incident
---

The Redis missing master incident occurs when the Redis cluster has no node marked as master. This can cause problems with the Redis service and may result in service disruptions or failures. It is important to address this issue promptly to ensure the smooth operation of the Redis service.

### Parameters
```shell
# Environment Variables

export REDIS_HOST="PLACEHOLDER"

export REDIS_PORT="PLACEHOLDER"

export IP_ADDRESS_OF_REDIS_MASTER_NODE="PLACEHOLDER"

export NODE_NAME="PLACEHOLDER"

export REDIS_CONFIG_FILE_PATH="PLACEHOLDER"

export MASTER_IP_ADDRESS="PLACEHOLDER"
```

## Debug

### Check Redis cluster status
```shell
redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} cluster info
```

### Check cluster nodes
```shell
redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} cluster nodes
```

### Check master node
```shell
redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} cluster nodes | grep master
```

### Check Redis logs for errors
```shell
tail -n 100 /var/log/redis/redis-server.log
```

### Check Redis configuration file
```shell
cat /etc/redis/redis.conf
```

### Check Redis process status
```shell
systemctl status redis
```

### Check Redis service logs for errors
```shell
journalctl -u redis.service --no-pager | tail -n 100
```

### A node that was previously marked as the Redis master has failed or is no longer available.
```shell
bash

#!/bin/bash



# Set the IP address of the Redis cluster master node

REDIS_MASTER=${IP_ADDRESS_OF_REDIS_MASTER_NODE}



# Ping the Redis master node to check if it is reachable

ping -c 1 $REDIS_MASTER



# Check if the Redis master node is responding to Redis requests

redis-cli -h $REDIS_MASTER ping


```

## Repair

### If there are no Redis nodes marked as a master, promote a suitable node to become the master.
```shell


#!/bin/bash



# Set the Redis node that will be promoted to master

REDIS_NODE=${NODE_NAME}



# Promote the Redis node to master

redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} cluster failover force


```

### If the master node is down, bring it back up and ensure it is correctly marked as the master.
```shell


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


```