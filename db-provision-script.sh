echo ---------------------- I am provisioning at DB... -------------------------------------

sudo apt-get update && sudo apt-get upgrade -y

sudo apt-get -y install mysql-server

sudo cp /etc/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld-backup.cnf
sed -i '0,/127.0.0.1/{s/127.0.0.1/0.0.0.0/}' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart

sudo mysql -e "CREATE USER 'DB_USER'@'192.168.56.101' IDENTIFIED BY 'DB_PASS';"
sudo mysql -e "CREATE DATABASE DB_NAME;"
sudo mysql -e "GRANT ALL PRIVILEGES ON DB_NAME . * TO 'DB_USER'@'192.168.56.101';"
sudo mysql -e "FLUSH PRIVILEGES;"

date > /etc/vagrant_provisioned_DB_at

$GITHUB_TOKEN
