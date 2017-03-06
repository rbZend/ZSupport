#!/bin/bash

# this script is supposed to prepare ZS to log into named pipes instead of regular log files

echo "This script uses Zend Server's WebAPI, therefore, it needs the WebAPI Key credentials."
echo

echo -e "Enter the key name (usually - admin) : \c"
read -r name
echo -e "Enter the key secret (long hash) : \c"
read -r sec

mkdir /usr/local/zend/var/log/pipes
chmod 777 /usr/local/zend/var/log/pipes
/usr/local/zend/bin/zs-manage store-directive -d zend.log_dir -v /usr/local/zend/var/log/pipes -N $name -K $sec

echo
echo
echo "If the result above was OK, restart Zend Server"
echo

