#!/bin/bash

instanceIds=('i-02d299297d64d77f7' 'i-0dd9198b3b8572a85')

_date=`date +'%d.%m.%Y'`


sshkey=`grep -w sshkey .conf | cut -d '=' -f 2`
user=`grep -w user .conf | cut -d '=' -f 2`
password=`grep -w password .conf | cut -d '=' -f 2`
host=`grep -w host .conf | cut -d '=' -f 2`
database=`grep -w database .conf | cut -d '=' -f 2`
albendpoint=`grep -w albendpoint .conf | cut -d '=' -f 2`

for ip in ${instanceIds[@]};do
_time=`date +'%T'`

error_report(){
    echo "Server $ip : Line number $1" >> error.log
}
trap 'error_report $LINENO' ERR

echo "${_time} Checking HTTP Status"
status=$(ssh -o StrictHostKeyChecking=no -i $sshkey -q ec2-user@$ip  "systemctl status httpd | grep Active: | sed -e 's/^[[:space:]]*//' | cut -d ' ' -f 2" 2>/dev/null) 
echo "${_time} status is ${status}"

if [[ $status == "inactive" ]]
then 
echo "${_time} starting HTTP server"
httpdstart=$(ssh -i $sshkey -q ec2-user@$ip  "sudo systemctl start httpd" 2>/dev/null)
fi

echo "${_time} checking loadbalancer response code"
code=$(curl --write-out '%{http_code}' --silent --output /dev/null $albendpoint )
echo "${_time} response code is ${code}"


if [ $code -ne '200' ]
then
echo "${_time} sending mail"
python ../send_mail.py "Response Code" $code 
fi

echo "${_time} inserting into database"
insert=$(ssh -i $sshkey -q ec2-user@$ip  "mysql -u admin -h $host --password=$password -e \"use webserver; INSERT INTO responses VALUES ('$ip',$code,'$status','$_date','$_time');\"" 2>/dev/null)

done

_time=`date +'%T'`
if [ -f "error.log" ]
then
    echo "${_time} sending error mail"
    python ../send_mail.py "Web Server" "$PWD/error.log"
else
    echo "${_time} All completed"
fi