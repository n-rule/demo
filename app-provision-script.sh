#!/bin/bash

echo ---------------------- I am provisioning at APP... ------------------------------------
date > /etc/vagrant_provisioned_APP_at

# Moving env variables previously copied in vagrant config - FOR TESTING PURPOSE ONLY
sudo mv //home/vagrant/env.sh /etc/profile.d/
source /etc/profile.d/env.sh


sudo apt-get update && sudo apt-get upgrade -y
#sudo apt install default-jdk mysql-client -y
sudo apt install openjdk-11-jre mysql-client -y


#adduser --disabled-password --gecos "" app-user

# 6 DIGITS PASSWORD GENERATOR
#openssl rand -base64 6

sudo useradd -p $(openssl passwd -1 password) app-user
#sudo -i -u app-user /bin/bash - LOGIN AS ROOT without confirming password

export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"

#Pulling app form github
sudo git clone https://github.com/spring-projects/spring-petclinic.git /home/app-user/petclinic
cd /home/app-user/petclinic
sudo chmod +x mvnw
./mvnw package -Dmaven.test.skip

# COPYing OR CREATING petclinic.serviceS at /etc/systemd/system
# CAUTION - Service workability highly depends on app version in github host. (EXEC JAR NAME)
sudo cp //home/vagrant/petclinic-main.service //home/vagrant/petclinic-backup.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start petclinic-main.service 
sudo systemctl enable petclinic-main.service

#HEALTHCHECK APPENDING TO MAIN CRONTAB
sudo chmod +x //home/vagrant/healtcheck.sh
echo "* * * * * vagrant /home/vagrant/healthcheck.sh" | sudo tee -a /etc/crontab

# sudo java -jar target/*.jar & - STARTING WITH H2 Local database
#java -Dspring.profiles.active=mysql -jar target/*.jar - WORKING ONE, disabled due running java as proce


