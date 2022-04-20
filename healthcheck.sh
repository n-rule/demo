#!/bin/bash

up='{"status":"UP"}'

response=$(curl http://192.168.56.101:8080/actuator/health)

service_status=$(sudo systemctl is-failed petclinic-main)

#mysql_status=$(mysqladmin --host=192.168.56.102 --user=db_user --password=db_pass ping 2>/dev/null)

mysqladmin -h 192.168.56.102 ping
mysql_exit=$?

if [ "$mysql_exit" = 0 ]; then 
  mysql_status="MySQL is alive"
  sudo systemctl stop petclinic-backup.service 
  else
  mysql_status="MySQL is DEAD"
fi 

if [ "$service_status" == "active" ]; then
  status_report="Running on remote MySQL"
else
  status_report="Running on localhost"
fi

if [ "$response" == "$up" ]; then
  echo "$(date) - $response - $status_report - $mysql_status">> /home/vagrant/1.log 
else
  echo "$(date) - $response" >> /home/vagrant/1.log
  sudo systemctl restart petclinic-main.service 
fi


