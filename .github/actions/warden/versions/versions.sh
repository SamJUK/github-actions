#!/usr/bin/env bash
# Prints the service versions a Warden .env runs, as key=value lines.
# Defaults and on/off rules follow Warden 0.16.1 (commands/env.cmd and environments/includes/*.base.yml).
set -euo pipefail

env_file=${1:-.env}
[ -f "$env_file" ] || { echo "::error::Warden env file not found: $env_file" >&2; exit 1; }

# Last assignment wins, as when Warden sources the file. Never eval: the file is data.
get() {
    local value
    value=$(sed 's/\r$//' "$env_file" | grep -E "^$1=" | tail -n1 | cut -d= -f2-) || true
    value=${value%\"}; value=${value#\"}; value=${value%\'}; value=${value#\'}
    printf '%s' "${value:-$2}"
}

type=$(get WARDEN_ENV_TYPE '')
[ -n "$type" ] || { echo "::error::$env_file has no WARDEN_ENV_TYPE" >&2; exit 1; }

on_by_default=1; [ "$type" = local ] && on_by_default=0
magento2_default=0; [ "$type" = magento2 ] && magento2_default=1

# when <toggle> <toggle default> <version key> <version default>
when() { if [ "$(get "$1" "$2")" = 1 ]; then get "$3" "$4"; fi; }

echo "php=$(get PHP_VERSION 7.4)"
echo "composer=$(get COMPOSER_VERSION '')"
echo "node=$(get NODE_VERSION '')"

db_distribution=''; db_version=''
if [ "$(get WARDEN_DB $on_by_default)" = 1 ]; then
    db_distribution=$(get MYSQL_DISTRIBUTION mariadb)
    db_version=$(get MYSQL_DISTRIBUTION_VERSION "$(get MARIADB_VERSION 10.6)")
fi
mariadb=''; mysql=''
[ "$db_distribution" = mariadb ] && mariadb=$db_version
[ "$db_distribution" = mysql ] && mysql=$db_version
echo "db_distribution=$db_distribution"
echo "mariadb=$mariadb"
echo "mysql=$mysql"

echo "opensearch=$(when WARDEN_OPENSEARCH 0 OPENSEARCH_VERSION 1.2)"
echo "elasticsearch=$(when WARDEN_ELASTICSEARCH $magento2_default ELASTICSEARCH_VERSION 8.11)"
echo "redis=$(when WARDEN_REDIS $on_by_default REDIS_VERSION 5.0)"
echo "valkey=$(when WARDEN_VALKEY 0 VALKEY_VERSION 8.1)"
echo "nginx=$(when WARDEN_NGINX $on_by_default NGINX_VERSION 1.16)"
echo "varnish=$(when WARDEN_VARNISH $magento2_default VARNISH_VERSION 6.0)"
echo "rabbitmq=$(when WARDEN_RABBITMQ $magento2_default RABBITMQ_VERSION 3.8)"
