#!/bin/bash

# this script is supposed to prepare ZS to log into named pipes instead of regular log files

cat <<EOM

This script uses Zend Server's WebAPI, therefore, it needs the WebAPI Key credentials.
The API keys can be obtained and created through Zend Server UI, for example:
    http://localhost:10081/ZendServer/ApiKeys/
For this script to work correctly, you need an Administrator level API key.

EOM

if [ -w /etc/passwd ]; then
	echo "Superuser priveleges confirmed..."
	echo
else
	echo "You need to be superuser (root) to run this script"
	exit 1
fi

echo -e "Enter the key name (usually - admin) : \c"
read -r name
echo -e "Enter the key secret (long hash) : \c"
read -r sec

mkdir /usr/local/zend/var/log/pipes
chmod 777 /usr/local/zend/var/log/pipes

/usr/local/zend/bin/zs-manage store-directive -d zend.log_dir -v /usr/local/zend/var/log/pipes -N $name -K $sec
sleep 1
echo
echo
echo "Turning off Zend Server's log rotation"
echo

lR="zend_datacache.log_rotation_size=0&zend_jobqueue.log_rotation_size=0&zend_statistics_extension.log_rotation_size=0&zend_pagecache.log_rotation_size=0&zend_codetracing.log_rotation_size=0&zend_monitor.log_rotation_size=0&zend_sc.log_rotation_size=0&zend_extension_manager.log_rotation_size=0&zend_jobqueue.daemon.log_rotation_size=0&zend_monitor.daemon.log_rotation_size=0&zend_sc.daemon.log_rotation_size=0&zend_deployment.daemon.log_rotation_size=0&zend_url_insight.log_rotation_size"

echo "Setting verbosity 5 for all the logs"
lV="zend_statistics.log_verbosity_level=5&zend_statistics_extension.log_verbosity_level=5&zend_jobqueue.log_verbosity_level=5&zend_url_insight.log_verbosity_level=5&zend_datacache.log_verbosity_level=5&zend_utils.log_verbosity_level=5&zend_pagecache.log_verbosity_level=5&zend_sc.log_verbosity_level=5&zend_jobqueue.daemon.log_verbosity_level=5&zend_sc.daemon.log_verbosity_level=5&zend_deployment.daemon.log_verbosity_level"

/usr/local/zend/bin/zs-client.sh configurationStoreDirectives --zskey=$name --zssecret=$sec --output-format=kv --directives="$lR"
sleep 3

/usr/local/zend/bin/zs-client.sh configurationStoreDirectives --zskey=$name --zssecret=$sec --output-format=kv --directives="$lV"
sleep 3

echo "Changing the values for ZSD..."
sed -i 's@zend_server_daemon\.log_rotation_size=.*$@zend_server_daemon.log_rotation_size=0@' /usr/local/zend/etc/zsd.ini
sed -i 's@zend_server_daemon\.log_verbosity_level=.*$@zend_server_daemon.log_verbosity_level=5@' /usr/local/zend/etc/zsd.ini
sleep 1

node=$(cat /usr/local/zend/etc/conf.d/ZendGlobalDirectives.ini | grep "zend\.node_id" | cut -d"=" -f2)

/usr/local/zend/bin/zs-client.sh configurationApplyChanges --zskey=$name --zssecret=$sec --output-format=kv --serverId=$node
echo
sleep 2


/usr/local/zend/bin/zendctl.sh stop
cd /usr/local/zend/var/log || exit
rm pipes/*
mkdir old_logs
mv *.log old_logs/
mv old_logs/php.log old_logs/error.log old_logs/access.log .
echo
echo "Now run Dispenser to create pipes and logs, then start Zend Server."
echo
