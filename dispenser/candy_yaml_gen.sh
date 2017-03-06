#!/bin/bash



while read ls; do
	lb=$(echo $ls | tr [:lower:] [:upper:])
	cat <<EOTPL
    -
        id: $lb
        input: /usr/local/zend/var/log/pipes/$ls.log
        output: /usr/local/zend/var/log/$ls.log
        # in lines
        dump_buffer: 50
        dump_upon:
            - " ERROR]"
        filters:
            show: *defaultShow
        full_output: false
        # in megabytes
        rotate_at: 10
EOTPL
done <<EOCMD
codetracing
datacache
deployment
jobqueue
jobqueue_ui
jqd
monitor
monitor_node
monitor_ui
pagecache
scd
sc
statistics
url_insight_daemon
url_insight
utils
zdd
zem
zray
zsd
zs_maintenance
EOCMD

