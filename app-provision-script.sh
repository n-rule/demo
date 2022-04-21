#!/bin/bash

echo ---------------------- I am provisioning at APP... ------------------------------------
date > /etc/vagrant_provisioned_APP_at

# Moving env variables previously copied in vagrant config
sudo mv //home/vagrant/env.sh /etc/profile.d/
source /etc/profile.d/env.sh

sudo apt-get update && sudo apt-get upgrade -y
#sudo apt install default-jdk mysql-client -y
sudo apt install openjdk-11-jre mysql-client -y

# CHECKING IF MYSQL IS ALIVE, IF DB IS UP AND CREDENTIALS ARE RIGHT THEN RESPOND WILL BE "mysqld is alive" ELSE ITS EMPTY
mysql_ping=$(mysqladmin --host=$MYSQL_IP --user=$MYSQL_USER --password=$MYSQL_PASS ping)
if [ -z "$mysql_ping" ]; then 
  echo "DB IS DEAD" 
  exit
fi

#adduser --disabled-password --gecos "" app-user

# 6 DIGITS PASSWORD GENERATOR
#openssl rand -base64 6

sudo useradd -p $(openssl passwd -1 $APP_PASS) $APP_USER
#sudo -i -u app-user /bin/bash - LOGIN AS ROOT without confirming password

#export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64" - NOT necessary

#Pulling app from github
sudo git clone https://github.com/spring-projects/spring-petclinic.git /home/$APP_USER/petclinic
cd /home/$APP_USER/petclinic
sudo chmod +x mvnw
./mvnw package -Dmaven.test.skip

#CREATING ENVIRONMENT VARIABLES FILE FOR SYSTEMD USING SYSTEM ENVS
sudo tee /etc/systemd/petclinic-env.conf >/dev/null <<EOF
MYSQL_USER=$MYSQL_USER
MYSQL_PASS=$MYSQL_PASS
MYSQL_URL=jdbc:mysql://$MYSQL_IP:3306/$MYSQL_DB
APP_USER=$APP_USER
EOF

# COPYing OR CREATING petclinic.serviceS at /etc/systemd/system
# CAUTION - Service workability highly depends on app version in github host. (EXEC JAR NAME)
sudo mv //home/vagrant/petclinic-main.service //home/vagrant/petclinic-backup.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start petclinic-main.service 
sudo systemctl enable petclinic-main.service

# Making HEALTHCHECK executible. Adding to global crontab
sudo chmod +x //home/vagrant/healthcheck.sh
echo "* * * * * vagrant /home/vagrant/healthcheck.sh" | sudo tee -a /etc/crontab


#--------------------------------------------------------------------------
# sudo java -jar target/*.jar & - STARTING WITH H2 Local database
#java -Dspring.profiles.active=mysql -jar target/*.jar - WORKING ONE, disabled due running java as proce


