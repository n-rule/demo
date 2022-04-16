echo ---------------------- I am provisioning at DB... -------------------------------------

sudo mv //home/vagrant/env.sh /etc/profile.d/
source /etc/profile.d/env.sh

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get -y install mysql-server

sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld-backup.cnf
sed -i '0,/127.0.0.1/{s/127.0.0.1/0.0.0.0/}' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

sudo mysql -e "CREATE USER '$MYSQL_USER'@'192.168.56.101' IDENTIFIED BY '$MYSQL_PASS';"
sudo mysql -e "CREATE DATABASE $MYSQL_DB;"
sudo mysql -e "GRANT ALL PRIVILEGES ON $MYSQL_DB . * TO '$MYSQL_USER'@'192.168.56.101';"
sudo mysql -e "FLUSH PRIVILEGES;"

date > /etc/vagrant_provisioned_DB_at

#sudo netstat -nlp | grep 8080

# WORKING WITH MYSQL
# SHOW DATABASES; - subj
# SELECT User, host FROM mysql.user; - showing all availablw users from all hosts
# show grants for db_user@192.168.56.101; - checking user privileges
# mysql -u $MYSQL_USER -p $MYSQL_DB -h 192.168.56.102 - check remote ddb connection


