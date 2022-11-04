#! /bin/bash

#Variable for the domain name of the machine

my_domain="SRV-LIN-02"

#Set the domain to the name of the server "SRV.LIN-02"

hostnamectl set-hostname $my_domain
hostname -f

#Variable for the path to the script

FILE="/usr/local/bin/occ"

#Script that aid tu runn occ command

cat <<EOL >$FILE
#! /bin/bash
cd /var/www/owncloud
sudo -E -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOL

#Change the file that it can be executable

chmod +x $FILE

#Install the packages for MariaDB, Apache, PHP and PHP smbclient

apt install -y \
  apache2 libapache2-mod-php \
  mariadb-server openssl redis-server wget php-imagick \
  php-common php-curl php-gd php-gmp php-bcmath php-imap \
  php-intl php-json php-mbstring php-mysql php-ssh2 php-xml \
  php-zip php-apcu php-redis php-ldap php-phpseclib
apt-get install -y libsmbclient-dev php-dev php-pear

#Install php smbclient module

pecl channel-update pecl.php.net
mkdir -p /tmp/pear/cache
pecl install smbclient-stable
echo "extension=smbclient.so" > /etc/php/7.4/mods-available/smbclient.ini
phpenmod smbclient
systemctl restart apache2

#Variable for the path to the script

FILE="/etc/apache2/sites-available/owncloud.conf"

#Create a file and configure the service Apache

cat <<EOM >$FILE
<VirtualHost *:80>
# uncommment the line below if variable was set
#ServerName $my_domain
DirectoryIndex index.php index.html
DocumentRoot /var/www/owncloud
<Directory /var/www/owncloud>
  Options +FollowSymlinks -Indexes
  AllowOverride All
  Require all granted

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
</VirtualHost>
EOM

#Enable the 2 Virtual host configurations

a2dissite 000-default
a2ensite owncloud.conf

#Configuration of the Database

sed -i "/\[mysqld\]/atransaction-isolation = READ-COMMITTED\nperformance_schema = on" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl start mariadb
mysql -u root -e "CREATE DATABASE IF NOT EXISTS owncloud; \
GRANT ALL PRIVILEGES ON owncloud.* \
  TO owncloud@localhost \
  IDENTIFIED BY '${sec_db_pwd}'";

#Enable the Apaches Modules

a2enmod dir env headers mime rewrite setenvif
systemctl restart apache2

#Install the packages tar 

sudo apt-get update -y tar

#Download OwnCloud

cd /var/www/
wget https://download.owncloud.com/server/stable/owncloud-complete-latest.tar.bz2 && \
tar -xjf owncloud-complete-latest.tar.bz2 && \
chown -R www-data. owncloud

#Password OwnCloud Admin and DB

sec_db_pwd="Password"
sec_admin_pwd="Password"

#Install OwnCloud

occ maintenance:install \
    --database "mysql" \
    --database-name "owncloud" \
    --database-user "owncloud" \
    --database-pass $sec_db_pwd \
    --data-dir "/var/www/owncloud/data" \
    --admin-user "admin" \
    --admin-pass $sec_admin_pwd

#Variable wich contains the IP of the SRV-LIN-02

my_ip="10.10.10.12"

#Configure Owncloud Domain

occ config:system:set trusted_domains 1 --value="$my_ip"
occ config:system:set trusted_domains 2 --value="$my_domain"




