#!/bin/sh
#Description:定时任务脚本，通过PID和time来控制进程启动
#Author:学在囧途
#Time:2013.12.17 11:16:36
params=$1
cd `dirname $0`

function doUcssh2()
{
        echo $$ > Ucssh2.pid
        echo `date "+%Y-%m-%d %H:%M:%S"` >> Ucssh2.pid
        source ~/.bash_profile
        php runUcssh2.php
        rm -rf Ucssh2.pid
}

if [ $params = "crontab" ]; then
	if [ ! -f "Ucssh2.pid" ]; then
		doUcssh2
	else
		modifytime=`stat -c %Y Ucssh2.pid`
		nowtime=`date +%s`
		pid=`head -1 Ucssh2.pid`
		if [ $[ $nowtime - $modifytime ] -gt 3600 ]; then
			rm -rf Ucssh2.pid
			kill -9 $pid
			doUcssh2		
		fi
		exit
	fi
elif [ $params = "run" ]; then
	pid=`head -1 Ucssh2.pid`
	kill -9 $pid
	rm -rf Ucssh2.pid
	doUcssh2
elif [ $params = "-help" ]; then
	echo "Run Ucssh2.sh needs params 'crontab' or 'run'"
	echo "Params:crontab"
	echo "              it prepare for crontab to run it"
        echo "Params:run"
	echo "          it prepare for someone to run it at once"
	exit
else
	echo "Run Ucssh2.sh needs params 'crontab' or 'run',please retry it..."
	echo "If you need help,please enter './Ucssh2.sh -help'"
	exit
fi









