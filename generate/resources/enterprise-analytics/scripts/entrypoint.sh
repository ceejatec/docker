#!/bin/bash
set -e

staticConfigFile=/opt/enterprise-analytics/etc/couchbase/static_config
restPortValue=8091

# see https://developer.couchbase.com/documentation/server/current/install/install-ports.html
function overridePort() {
    portName=$1
    portNameUpper=$(echo $portName | awk '{print toupper($0)}')
    portValue=${!portNameUpper}

    # only override port if value available AND not already contained in static_config
    if [ "$portValue" != "" ]; then
        if grep -Fq "{${portName}," ${staticConfigFile}
        then
            echo "Don't override port ${portName} because already available in $staticConfigFile"
        else
            echo "Override port '$portName' with value '$portValue'"
            echo "{$portName, $portValue}." >> ${staticConfigFile}

            if [ ${portName} == "rest_port" ]; then
                restPortValue=${portValue}
            fi
        fi
    fi
}

overridePort "rest_port"
overridePort "mccouch_port"
overridePort "memcached_port"
overridePort "query_port"
overridePort "ssl_query_port"
overridePort "fts_http_port"
overridePort "moxi_port"
overridePort "ssl_rest_port"
overridePort "ssl_capi_port"
overridePort "ssl_proxy_downstream_port"
overridePort "ssl_proxy_upstream_port"


[[ "$1" == "enterprise-analytics" ]] && {

    if [ "$(whoami)" = "couchbase" ]; then
        # Ensure that /opt/enterprise-analytics/var is owned by user 'couchbase' and
        # is writable
        if [ ! -w /opt/enterprise-analytics/var -o \
            $(find /opt/enterprise-analytics/var -maxdepth 0 -printf '%u') != "couchbase" ]; then
            echo "/opt/enterprise-analytics/var is not owned and writable by UID 1000"
            echo "Aborting as Couchbase Server will likely not run"
            exit 1
        fi
    fi

    # Ensure running on sufficient hardware
    if [ -e /opt/enterprise-analytics/bin/validate-cpu-microarchitecture.sh ]; then
        source /opt/enterprise-analytics/bin/validate-cpu-microarchitecture.sh
        validate_cpu_microarchitecture
    fi

    echo "Starting Couchbase Server -- Web UI available at http://<ip>:$restPortValue"
    echo "and logs available in /opt/enterprise-analytics/var/lib/couchbase/logs"
    exec runsvdir -P /etc/service
}

exec "$@"
