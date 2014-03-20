#!/bin/sh
#通过PID来判断进程是否存在，不存在则重新启动进程
#下面以sphinx为例子讲解
#Author:学在囧途
source  $HOME/.bash_profile
pidFile=$0
function doStart()
{
	echo "echo star sphinx"
	cd /home/uads/htdocs/sphinx/
	sh start.sh #start.sh启动脚本中要保存进程PID
}
if [ ! -f $pidFile ];then
	pid=`head -1 $pidFile`
	kill -0 $pid
	status=`echo $?`
	if [ status -eq 0 ];then
		echo "sphinx service is ok, pid is: $pid"
	fi
else
	doStart
fi
