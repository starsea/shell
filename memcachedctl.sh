#!/bin/sh
#Description:About memcached some action
#Author:xuezaijiongtu
#Time:2013.12.18

#Memcache Dir
MemDir=/home/ucpack/app/memcached/bin/

#Memcache Action Params
Params=$1

#The action of stop
function stop()
{
	kill `head -1 $MemDir"memcached.pid"`
	rm -rf $MemDir"memcached.pid"
	echo "Memcached has been already stop..."
}

#The action of start
function start()
{
	$MemDir"memcached" -d -m 2048  -u root -l 127.0.0.1 -p 11211 -c 1024 -P $MemDir"memcached.pid" 
	echo "Memcached has been already started..."
}

#The action of restart
function restart()
{
	if [ ! -f $MemDir"memcached.pid" ]; then
		start
	else
		stop
		start
		echo "Memcached has been already restart..."
	fi
}

if [ $Params = "stop" ]; then
	stop
elif [ $Params = "start" ]; then
	start
elif [ $Params = "restart" ]; then
	restart
else
	echo "Params is wrong,please try one more time like ./Memcachedctl.sh start|restart|stop"
	exit
fi
