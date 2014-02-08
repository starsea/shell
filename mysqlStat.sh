#!/bin/sh
#数据库数据监控
#Author:学在囧途


[ -f ~/.bash_profile ] && . ~/.bash_profile || export PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/mysql/bin

###################################################################################################
usage () {
cat <<EOF
Usage: $0 [OPTIONS]
  --socket=#          通过socket连接mysql时,请指定此参数,默认为/usr/local/mysql/tmp/3306/mysql.sock
  --interval=#        统计间隔时间,单位为秒,默认为10  
  --count=#           统计次数,默认为10次
  --user=#            连接数据库的用户名,未指定时,脚本执行过程中会提示输入
  --password=#        连接数据库的密码,未指定时,脚本执行过程中会提示输入
  --mysqldir=#        mysql命令所在目录,默认为/usr/local/mysql,若\$PATH中能找到mysql则不需设定  
  --host=#            通过IP或主机名访问,请指定此参数,若同时指定了--socket参数,则参数--host与--port无效
  --port=#            通过IP或主机名访问,请指定此参数,默认--port=3306  
EOF
        exit 1
}
   
if [ $# -ne 0 ] ; then   
   for arg do 
      val=`echo "$arg" | sed -e "s;--[^=]*=;;"`
      case "$arg" in
      --mysqldir=*)      mysqlDir="$val" ;;
      --socket=*)        socketFile="$val" ;;
      --user=*)          userName="$val" ;;
      --password=*)      password="$val" ;;
      --host=*)          hostName="$val" ;;
      --port=*)          portNum="$val" ;;
      --interval=*)      intervalTime="$val" ;;
      --count=*)         cycleCount="$val" ;;
      --help)            usage ;;
      *)  
      echo "parameter error"              
      echo "Usage sample:`basename $0` [ --socket=/usr/local/mysql/tmp/3306/mysql.sock  | --count=20 | --user=root | --password='xxxxxx'  ] "
      echo 
      usage
      exit 1 ;;
      esac
   done
fi
######################
[ -z $mysqlDir ] && mysqlDir=/usr/local/mysql
export PATH=$mysqlDir/bin:$mysqlDir:$PATH
which mysql > /dev/null 
if [ $? -ne 0 ] ; then
   echo "Can't find mysql command,please use `basename $0` --mysqldir=mysqlPathName"
   echo 
   usage 
   exit 1
fi  
##
if [ ! -z $socketFile ] ; then
   args="--socket=$socketFile "   
elif [ ! -z $hostName ] ; then
   [ -z portNum ] && $portNum=3306 ;
   args="-h $hostName -P $portNum "
else
   socketFile=/usr/local/mysql/tmp/3306/mysql.sock
   args="--socket=$socketFile " 
fi
##
if [ -z $userName ] ; then
   read -p "please input username:" userName 
fi   
if [ -z $password ] ; then
   read -s -p "please input password:" password
fi
args=$args" -u$userName  -p$password "
     
##
[ -z $intervalTime ] && intervalTime=10
[ -z $cycleCount ] && cycleCount=10


####################################################################################################
tmpFile=/tmp/.mystatus.$$
i=1
while [ $i -le $cycleCount ]
do 
##
select_rowsnum_e=0 && select_rowsnum_b=0
insert_rowsnum_e=0 && insert_rowsnum_b=0
update_rowsnum_e=0 && update_rowsnum_b=0
delete_rowsnum_e=0 && delete_rowsnum_b=0
##
mysql $args -e "show global status" | grep -i -E "com_select|com_insert|com_update|com_delete|Innodb_rows_deleted|Innodb_rows_inserted|Innodb_rows_read|Innodb_rows_updated|Qcache_hits" > ${tmpFile}
if [ $? -ne 0 ] ; then
   echo "Connect mysql failure,parameter or password error,exit"
   rm -f ${tmpFile} > /dev/null 2>&1
   exit 1
fi
while read statusName statusValue
do 
[ $statusName = "Com_select" ] && select_num_b=${statusValue} 
[ $statusName = "Qcache_hits" ] && qcache_num_b=${statusValue}
[ $statusName = "Com_update" ] && update_num_b=${statusValue} 
[ $statusName = "Com_delete" ] && delete_num_b=${statusValue} 
[ $statusName = "Com_insert" ] && insert_num_b=${statusValue} 
[ $statusName = "Innodb_rows_read" ]     && select_rowsnum_b=${statusValue} 
[ $statusName = "Innodb_rows_updated" ]  && update_rowsnum_b=${statusValue} 
[ $statusName = "Innodb_rows_deleted" ]  && delete_rowsnum_b=${statusValue} 
[ $statusName = "Innodb_rows_inserted" ] && insert_rowsnum_b=${statusValue} 
done < ${tmpFile}  

##
if [ $i -eq 1 ] ; then
  echo 
  if [ ! -z $socketFile ] ; then
			echo "mysql statistics(socket:$socketFile; interval:$intervalTime) "
	else
	    echo "mysql statistics(host:$hostName/$portNum ; interval:$intervalTime) "
	fi 
	echo "统计结果行数只计算innodb表，myisam表只计算次数，不包含行数，各列头代表含议如下"
	echo "select/s:每秒查询次数        selrows/s:每秒查询行数    rows/s/sel:每秒每次查询行数   qcache/s:每秒命中Qcache次数" 
	echo "insert/s:每秒插入次数        insrows/s:每秒插入行数    rows/s/ins:每秒每次插入行数" 
	echo "update/s:每秒更新次数        updrows/s:每秒更新行数    rows/s/upd:每秒每次更新行数" 
	echo "delete/s:每秒删除次数        delrows/s:每秒删除行数    rows/s/del:每秒每次删除行数"
  echo "-------------------------------------------------------------------------------------------------------------------------------------------------------"
fi 
sleep $intervalTime


##
statTime=$(date +%H:%M:%S)
mysql $args -e "show global status" | grep -i -E "com_select|com_insert|com_update|com_delete|Innodb_rows_deleted|Innodb_rows_inserted|Innodb_rows_read|Innodb_rows_updated|Qcache_hits" > ${tmpFile}
if [ $? -ne 0 ] ; then
   echo "Connect mysql failure,parameter or password error,exit"
   rm -f ${tmpFile} > /dev/null 2>&1
   exit 1
fi
while read statusName statusValue
do 
[ $statusName = "Com_select" ] && select_num_e=${statusValue}
[ $statusName = "Qcache_hits" ] && qcache_num_e=${statusValue}
[ $statusName = "Com_update" ] && update_num_e=${statusValue}
[ $statusName = "Com_delete" ] && delete_num_e=${statusValue}
[ $statusName = "Com_insert" ] && insert_num_e=${statusValue}
[ $statusName = "Innodb_rows_read" ]     && select_rowsnum_e=${statusValue} 
[ $statusName = "Innodb_rows_updated" ]  && update_rowsnum_e=${statusValue} 
[ $statusName = "Innodb_rows_deleted" ]  && delete_rowsnum_e=${statusValue} 
[ $statusName = "Innodb_rows_inserted" ] && insert_rowsnum_e=${statusValue} 
done < ${tmpFile}
 
## 
select_num=$(expr $(expr ${select_num_e} - ${select_num_b}) / $intervalTime)
qcache_num=$(expr $(expr ${qcache_num_e} - ${qcache_num_b}) / $intervalTime)
insert_num=$(expr $(expr ${insert_num_e} - ${insert_num_b}) / $intervalTime)
update_num=$(expr $(expr ${update_num_e} - ${update_num_b}) / $intervalTime)
delete_num=$(expr $(expr ${delete_num_e} - ${delete_num_b}) / $intervalTime)

select_rowsnum=$(expr $(expr ${select_rowsnum_e} - ${select_rowsnum_b}) / $intervalTime)
insert_rowsnum=$(expr $(expr ${insert_rowsnum_e} - ${insert_rowsnum_b}) / $intervalTime)
update_rowsnum=$(expr $(expr ${update_rowsnum_e} - ${update_rowsnum_b}) / $intervalTime)
delete_rowsnum=$(expr $(expr ${delete_rowsnum_e} - ${delete_rowsnum_b}) / $intervalTime)

[ ${select_num} -eq 0 ] && perselect_rows=0 || perselect_rows=$(expr ${select_rowsnum} / ${select_num})
[ ${insert_num} -eq 0 ] && perinsert_rows=0 || perinsert_rows=$(expr ${insert_rowsnum} / ${insert_num})
[ ${update_num} -eq 0 ] && perupdate_rows=0 || perupdate_rows=$(expr ${update_rowsnum} / ${update_num})
[ ${delete_num} -eq 0 ] && perdelete_rows=0 || perdelete_rows=$(expr ${delete_rowsnum} / ${delete_num})

##
if [ $(expr $i % 20) -eq 1 ] ; then
   if [ $i -ne 1 ] ; then
     echo 
   fi  
   echo "Time       select/s  selrows/s  rows/s/sel  qcache/s  insert/s  insrows/s  rows/s/ins  update/s  updrows/s  rows/s/upd  delete/s  delrows/s  rows/s/del"
fi
printf '%8s %10i %10i %11i %9i %9i %10i %11i %9i %10i %11i %9i %10i %11i \n' $statTime ${select_num} ${select_rowsnum} ${perselect_rows} ${qcache_num} ${insert_num} ${insert_rowsnum} ${perinsert_rows} ${update_num} ${update_rowsnum} ${perupdate_rows} ${delete_num} ${delete_rowsnum} ${perdelete_rows}


i=$(expr $i + 1)
done  
echo "-------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "end statistics"
rm -f ${tmpFile}
exit

