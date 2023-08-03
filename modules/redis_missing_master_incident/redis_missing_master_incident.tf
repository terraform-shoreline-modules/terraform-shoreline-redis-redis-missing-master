resource "shoreline_notebook" "redis_missing_master_incident" {
  name       = "redis_missing_master_incident"
  data       = file("${path.module}/data/redis_missing_master_incident.json")
  depends_on = [shoreline_action.invoke_redis_ping,shoreline_action.invoke_promote_redis_node,shoreline_action.invoke_redis_master_check_and_restart]
}

resource "shoreline_file" "redis_ping" {
  name             = "redis_ping"
  input_file       = "${path.module}/data/redis_ping.sh"
  md5              = filemd5("${path.module}/data/redis_ping.sh")
  description      = "A node that was previously marked as the Redis master has failed or is no longer available."
  destination_path = "/agent/scripts/redis_ping.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "promote_redis_node" {
  name             = "promote_redis_node"
  input_file       = "${path.module}/data/promote_redis_node.sh"
  md5              = filemd5("${path.module}/data/promote_redis_node.sh")
  description      = "If there are no Redis nodes marked as a master, promote a suitable node to become the master."
  destination_path = "/agent/scripts/promote_redis_node.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "redis_master_check_and_restart" {
  name             = "redis_master_check_and_restart"
  input_file       = "${path.module}/data/redis_master_check_and_restart.sh"
  md5              = filemd5("${path.module}/data/redis_master_check_and_restart.sh")
  description      = "If the master node is down, bring it back up and ensure it is correctly marked as the master."
  destination_path = "/agent/scripts/redis_master_check_and_restart.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_redis_ping" {
  name        = "invoke_redis_ping"
  description = "A node that was previously marked as the Redis master has failed or is no longer available."
  command     = "`chmod +x /agent/scripts/redis_ping.sh && /agent/scripts/redis_ping.sh`"
  params      = ["IP_ADDRESS_OF_REDIS_MASTER_NODE"]
  file_deps   = ["redis_ping"]
  enabled     = true
  depends_on  = [shoreline_file.redis_ping]
}

resource "shoreline_action" "invoke_promote_redis_node" {
  name        = "invoke_promote_redis_node"
  description = "If there are no Redis nodes marked as a master, promote a suitable node to become the master."
  command     = "`chmod +x /agent/scripts/promote_redis_node.sh && /agent/scripts/promote_redis_node.sh`"
  params      = ["REDIS_HOST","NODE_NAME","REDIS_PORT"]
  file_deps   = ["promote_redis_node"]
  enabled     = true
  depends_on  = [shoreline_file.promote_redis_node]
}

resource "shoreline_action" "invoke_redis_master_check_and_restart" {
  name        = "invoke_redis_master_check_and_restart"
  description = "If the master node is down, bring it back up and ensure it is correctly marked as the master."
  command     = "`chmod +x /agent/scripts/redis_master_check_and_restart.sh && /agent/scripts/redis_master_check_and_restart.sh`"
  params      = ["MASTER_IP_ADDRESS"]
  file_deps   = ["redis_master_check_and_restart"]
  enabled     = true
  depends_on  = [shoreline_file.redis_master_check_and_restart]
}

