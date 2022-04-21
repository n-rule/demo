#!/bin/bash

#mysql_status=$(mysqladmin --host=192.168.56.102 --user=db_user --password=db_pass ping 2>/dev/null)

# CHECKING STATUS OF MYSQL. GETTING EXIT CODE 0 IF MYSQL WILL ASK FOR PASSWORD. DO NOT NEED AUTHENTIFICATION
# STOPPING BACKUP-SERVICE IF MYSQL IS ALIVE

mysqladmin -h 192.168.56.102 ping
mysql_exit=$?

if [ "$mysql_exit" = 0 ]; then 
  mysql_status="MySQL is alive"
  sudo systemctl stop petclinic-backup.service 
  else
  mysql_status="MySQL is DEAD"
fi 

# CHECKING MAIN SERVICE STATUS FOR LOGGING 
service_status=$(sudo systemctl is-failed petclinic-main)
if [ "$service_status" == "active" ]; then
  status_report="Running on remote MySQL"
else
  status_report="Running on localhost"
fi


# GETTING RESPONSE FROM JAVA HEALTHCHECK. IF DOWN - RESTART MAIN-SERVICE FOR FAILOVER TO BACKUP-SERVICE
# LOGGING DATA TO 1.LOG
up='{"status":"UP"}'
response=$(curl http://192.168.56.101:8080/actuator/health)
if [ "$response" == "$up" ]; then
  echo "$(date) - $response - $status_report - $mysql_status">> /home/vagrant/1.log 
else
  echo "$(date) - $response" >> /home/vagrant/1.log
  sudo systemctl restart petclinic-main.service 
fi


