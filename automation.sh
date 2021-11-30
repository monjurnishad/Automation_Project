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

mv $logFileName /tmp

aws s3 cp /tmp/$logFileName s3://$bucket_name/$logFileName

