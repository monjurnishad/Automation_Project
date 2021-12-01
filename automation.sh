#!/bin/bash
name=monjur
bucket_name="upgrad-monjur"

sudo apt update -y

dpkg --status apache2 &> /dev/null

if [ $? -ne 0 ]; then
    sudo apt-get install -y apache2
    sudo systemctl start apache2
fi

sudo systemctl is-active apache2

if [ $? -ne 0 ]; then
    sudo systemctl start apache2
fi

sudo systemctl is-enabled apache2

if [ $? -ne 0 ]; then
    sudo systemctl enable apache2
fi

timestamp=$(date '+%d%m%Y-%H%M%S')
logFileName="$name-httpd-logs-$timestamp.tar"

cd "/var/log/apache2/"
tar -zcvf $logFileName *.log 

fileSize=$(du -smh $logFileName | awk '{print $1}')

mv $logFileName /tmp

aws s3 cp /tmp/$logFileName s3://$bucket_name/$logFileName

inventoryFile="/var/www/html/inventory.html"
cronFile="/etc/cron.d/automation"
tab="&nbsp;&nbsp;&nbsp;&nbsp;"
lineBreak="<br><br>"
header="<b>Log Type</b> $tab $tab $tab <b>Date Created</b> $tab $tab $tab <b>Type</b> $tab $tab $tab <b>Size</b>"


if [ ! -f $inventoryFile ]; then
    touch $inventoryFile
    echo $header >> $inventoryFile
fi 

echo $lineBreak >> $inventoryFile

echo "httpd-logs $tab $tab $tab $timestamp $tab $tab tar $tab $tab $tab $fileSize" >> $inventoryFile

if [ ! -f "$cronFile" ]; then
    touch $cronFile
    echo "* * * * * root /root/Automation_Project/automation.sh" >> $cronFile
fi
