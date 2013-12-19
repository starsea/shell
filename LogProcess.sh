#!/bin/sh
#Description:log处理
#Author:学在囧途
#Time:2013.12.18

#参数1:日志所在目录   *参数必须
#参数2:处理后的日志存放目录  *参数必须
#参数3:指定处理的日志  格式:20131121(即处理文件名中含有该字符串的日志文件)  *参数可选

ParamsNum=$#
filenamePatten="no"
if [ $ParamsNum -eq 2 ] ; then
	sourcePath=$1
	targetPath=$2
elif [ $ParamsNum -eq 3 ] ; then
	sourcePath=$1
	targetPath=$2
	filenamePatten=$3
else
     echo "Params more than 3,please check it..."
     exit
fi

#获取日志所在目录的所有文件名
for files in ${sourcePath}/*; do  
	filename=`basename $files`
	if [  $filenamePatten = "no" ]; then
		#处理所有文件 
		datefile=`echo $filename |grep -o "[0-9]\{8\}"`
		datetime=`echo $datefile|awk '{print substr($1, 1, 4) "-" substr($1, 5, 2) "-" substr($1, 7)}'`
		#创建目标目录
		mkdir -p $targetPath$datefile
		grep "^app(eve)" $sourcePath$filename |awk -F' serial' '{print "datetime='$datetime' "substr($1, index($1, " ") + 1, 8)"`"substr($2, index($2, "pageid="))}' > $targetPath$datefile"/"$filename
	else 
		#处理符合规则的日志文件
		datefile=`echo $filename |grep -o "[0-9]\{8\}"`
		datetime=`echo $datefile|awk '{print substr($1, 1, 4) "-" substr($1, 5, 2) "-" substr($1, 7)}'`
		#创建目标目录
		mkdir -p $targetPath$datefile
		if [ `echo $filename | grep -e $filenamePatten` ] ; then
			grep "^app(eve)" $sourcePath$filename |awk -F' serial' '{print "datetime='$datetime' "substr($1, index($1, " ") + 1, 8)"`"substr($2, index($2, "pageid="))}' > $targetPath$datefile"/"$filename
		
		fi      
		
	fi
done

echo "日志文件处理完毕..."
