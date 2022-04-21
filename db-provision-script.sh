#!/bin/bash

echo ---------------------- I am provisioning at DB... -------------------------------------

# Moving env variables previously copied in vagrant config
sudo mv //home/vagrant/env.sh /etc/profile.d/
source /etc/profile.d/env.sh

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get -y install mysql-server

# EDITING MYSQL.CONFIG TO ENABLE REMOTE CONNECTIONS TO DB
sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld-backup.cnf
sed -i '0,/127.0.0.1/{s/127.0.0.1/0.0.0.0/}' /etc/mysql/mysql.conf.d/mysqld.cnf
#sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

# CREATING USER, DB, ADD PRIVILEGES
mysql -u root <<MYSQL_SCRIPT
CREATE USER '$MYSQL_USER'@'192.168.56.101' IDENTIFIED BY '$MYSQL_PASS';
CREATE DATABASE $MYSQL_DB;
GRANT ALL PRIVILEGES ON $MYSQL_DB . * TO '$MYSQL_USER'@'192.168.56.101';
FLUSH PRIVILEGES;
MYSQL_SCRIPT


date > /etc/vagrant_provisioned_DB_at

#sudo netstat -nlp | grep 8080

# WORKING WITH MYSQL
# SHOW DATABASES; - subj
# SELECT User, host FROM mysql.user; - showing all availablw users from all hosts
# show grants for db_user@192.168.56.101; - checking user privileges
# mysql -u $MYSQL_USER -p $MYSQL_DB -h 192.168.56.102 - check remote ddb connection


