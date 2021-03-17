#!/bin/bash

bucket=lsegbucketname
rm -f error.log
today=`date +'%d-%m-%Y'`
_time=`date +'%T'`
_ip=`cut -d '.' -f 1 /etc/hostname`
error_report(){
    echo "Line number $1" >> error.log
}
trap 'error_report $LINENO' ERR

cd /var/log/httpd
echo "${_time} creating log location"
mkdir ${today}
mv access_log error_log ${today}/ 
echo "${_time} creating archive"
tar -cvzf ${today}-${_ip}.tgz ${today} --remove-files 
mv ${today}-${_ip}.tgz /home/ec2-user/
echo "${_time} uploading archive to S3" 
aws s3 cp /home/ec2-user/${today}-${_ip}.tgz S3://$bucket

if [ -f "./error.log" ]
then
    echo "${_time} sending error mail"
    python ../send_mail.py "Daily Backup" "error.log"
    rm -rf ${today}*
    exit 1
else
    echo "${_time} clearing the archived log file"
    rm -rf ${today}*
    exit 0
fi