echo ---------------------- I am provisioning at APP... ------------------------------------
date > /etc/vagrant_provisioned_APP_at

sudo mv //home/vagrant/env.sh /etc/profile.d/
source /etc/profile.d/env.sh




sudo apt-get update && sudo apt-get upgrade -y
sudo apt install default-jdk maven mysql-client -y


#adduser --disabled-password --gecos "" app-user

# PASSWORD GENERATOR
#openssl rand -base64 6


sudo useradd -p $(openssl passwd -1 password) app-user
sudo git clone https://n-rule:$GITHUB_TOKEN@github.com/Rudya93/Demo.git /home/app-user/petclinic
cd /home/app-user/petclinic
sudo mvn clean package -Dmaven.test.skip
# sudo java -jar target/*.jar &

sudo java -jar -Dspring.profiles.active=mysql target/*.jar &

#sudo bash ./mvnw package
#sudo mvn clean package -Dmaven.test.skip

