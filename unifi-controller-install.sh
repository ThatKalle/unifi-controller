# Complete script reference to installing UniFi Controller on Ubuntu 16.04.2
#
# The procedure sets up a UniFi Controller instance with default settings
# Protected by fail2ban with automated backups to Backblacze B2


# Add Linux user "user" with password "PASSWORD"
adduser user
#	PASSWORD
#	Y
adduser user sudo
exit

# ssh as user
# Disable root login
sudo nano /etc/ssh/sshd_config
	PermitRootLogin no
sudo service ssh restart
 
# Set TimeZone to Europe/Stockholm
# Fund yours with timedatectl list-timezones
sudo timedatectl set-timezone Europe/Stockholm
 
# Update apt-get source list and upgrade all packages.
sudo apt-get update && sudo apt-get upgrade -y

# Set up Automatic Security Updates
sudo apt-get install unattended-upgrades -y
touch /etc/apt/apt.conf.d/20auto-upgrades
echo -e 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades
/etc/init.d/unattended-upgrades restart
 
# Allow ports on UFW firewall.
# https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used
sudo ufw allow 22/tcp # SSH
sudo ufw allow 443/tcp # HTTPS
sudo ufw allow 8080/tcp # Inform
sudo ufw allow 8443/tcp # Web GUI
sudo ufw allow 8843/tcp # HTTPS Portal
sudo ufw allow 8880/tcp # HTTP Portal
sudo ufw allow 3478/udp # STUN
 
# Enable UFW firewall.
sudo ufw --force enable
 
# Add Ubiquiti UniFi repo to system source list.
# https://help.ubnt.com/hc/en-us/articles/220066768-UniFi-How-to-Install-Update-via-APT-on-Debian-or-Ubuntu
sudo echo 'deb http://www.ubnt.com/downloads/unifi/debian unifi5 ubiquiti' | sudo tee -a /etc/apt/sources.list.d/100-ubnt.list
 
# Add Ubiquiti GPG Keys
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50
 
# Update source list to include the UniFi repo then install Ubiquiti UniFi.
sudo apt-get update && sudo apt-get install unifi -y
 
# Install Fail2Ban
sudo apt-get install fail2ban -y
 
# Copy config Fail2ban config files to preserve overwriting changes during Fail2ban upgrades.
sudo cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
 
# Create ubiquiti Fail2ban definition and set fail regex.
sudo echo -e '# Fail2Ban filter for Ubiquiti UniFi\n#\n#\n\n[Definition]\nfailregex =^.*Failed .* login .* <HOST>*\s*$' | sudo tee -a /etc/fail2ban/filter.d/ubiquiti.conf
 
# Add ubiquiti JAIL to Fail2ban setting log path and blocking IPs after 3 failed logins within 15 minutes for 1 hour.
sudo echo -e '\n[ubiquiti]\nenabled = true\nfilter = ubiquiti\nlogpath = /usr/lib/unifi/logs/server.log\nmaxretry = 3\nbantime = 3600\nfindtime = 900\nport = 8443' | sudo tee -a /etc/fail2ban/jail.local
 
# Restart Fail2ban to apply changes above.
sudo service fail2ban restart

# Prerequisites
sudo mkdir /usr/local/bin
sudo apt-get install wget openssl -y
# Make sure sudo has a Crontab
sudo crontab -e
# REMEBER TO CHANGE;
# UNIFI.CONTROLLER.NAME
# -password pass:PASSWORD
# -srcstorepass PASSWORD
# Make sure to change the same vaules at the Cron Job stage aswell.
 
# Open https (tcp:443) using UFW
sudo ufw allow 443/tcp
sudo ufw --force enable
# This can be done in other ways, for example sudo iptables -A INPUT -p tcp -m tcp --sport 443 -j ACCEPT
 
# Set up LetsEncrypt with Certbot
# Navigate to system folder
cd /usr/local/bin
# Download certbot-auto
sudo wget https://dl.eff.org/certbot-auto
# Make Certbot-auto executable
sudo chmod a+x certbot-auto
# Install Certbot
yes | ./certbot-auto
# Generate a request for LetsEncrypt
./certbot-auto certonly --standalone --standalone-supported-challenges tls-sni-01 --register-unsafely-without-email --agree-tos -d UNIFI.CONTROLLER.NAME
 
# Convert cert to PKCS #12 format
sudo openssl pkcs12 -export -inkey /etc/letsencrypt/live/UNIFI.CONTROLLER.NAME/privkey.pem -in /etc/letsencrypt/live/UNIFI.CONTROLLER.NAME/fullchain.pem -out /usr/local/bin/lecert.p12 -name ubnt -password pass:PASSWORD
 
# Install certificate on UniFi Controller
sudo keytool -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore /var/lib/unifi/keystore -srckeystore /usr/local/bin/lecert.p12 -srcstoretype PKCS12 -srcstorepass PASSWORD -alias ubnt -noprompt
# Cleanup
sudo rm /usr/local/bin/lecert.p12
# Restart UniFi Service to enable the new certificate
sudo /etc/init.d/unifi restart
 
# Automated Cron Job for Renewal
# Create renew_lets_encrypt_cert.sh script
sudo touch /usr/local/bin/renew_lets_encrypt_cert.sh
sudo echo -e '#!/bin/bash\n# Get the certificate from LetsEncrypt\n/usr/local/bin/certbot-auto renew --quiet --no-self-upgrade\n# Convert cert to PKCS #12 format\n/usr/bin/openssl pkcs12 -export -inkey /etc/letsencrypt/live/UNIFI.CONTROLLER.NAME/privkey.pem -in /etc/letsencrypt/live/UNIFI.CONTROLLER.NAME/fullchain.pem -out /usr/local/bin/lecert.p12 -name ubnt -password pass:PASSWORD\n# Load it into the java keystore that UBNT understands\n/usr/bin/keytool -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore /var/lib/unifi/keystore -srckeystore /usr/local/bin/lecert.p12 -srcstoretype PKCS12 -srcstorepass PASSWORD -alias ubnt -noprompt\n# Clean up and use new cert\nrm /usr/local/bin/lecert.p12\n/etc/init.d/unifi restart' | sudo tee -a /usr/local/bin/renew_lets_encrypt_cert.sh
# Make renew_lets_encrypt_cert.sh script executable
sudo chmod +x /usr/local/bin/renew_lets_encrypt_cert.sh
# Schedule Cron Job to run renew_lets_encrypt_cert.sh every Monday
sudo crontab -l | { cat; echo "1 1 * * 1 /usr/local/bin/renew_lets_encrypt_cert.sh"; } | sudo crontab -

# Read access to UniFi backup directory
sudo chmod -R 705 /var/lib/unifi/backup/
 
# Set up rclone for use with Backblaze B2
# https://rclone.org/
# https://www.backblaze.com/b2/cloud-storage.html
cd /tmp
sudo apt-get install unzip -y
curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
cd rclone-*-linux-amd64

# Install rclone
# Binary
sudo cp rclone /usr/sbin/
sudo chown root:root /usr/sbin/rclone
sudo chmod 755 /usr/sbin/rclone
# Manpage
sudo mkdir -p /usr/local/share/man/man1
sudo cp rclone.1 /usr/local/share/man/man1/
sudo mandb 
 
# Configure rclone for use with Backblaze B2
# Use your bucket settings
rclone config
n # New Config
	B2_UNIFI.CONTROLLER.NAME # Select a Name
	3 # 3 for Backblaze B2
	123456abcdef # Provide Accound ID
	123456abcdef123456abcdef123456abcdef123abc # Provdie Application Key
    # Blank Endpoint
	y # Save
	q
 
# Automate backups with rclone
touch /usr/local/bin/unifi_b2_backup.sh
sudo echo -e '#!/bin/bash\ncd /tmp\n# Backup /var/lib/unifi/backup\nTIMESTMP=$(date +'%Y%m%d_%H%M%S')\ntar -zcvf backup.$TIMESTMP.tar.gz /var/lib/unifi/backup\n/usr/sbin/rclone copy /tmp/backup.$TIMESTMP.tar.gz B2_UNIFI.CONTROLLER.NAME:BUCKETNAME\nrm backup.$TIMESTMP.tar.gz\n\n# Backup /var/lib/unifi/sites\nTIMESTMP=$(date +'%Y%m%d_%H%M%S')\ntar -zcvf sites.$TIMESTMP.tar.gz /var/lib/unifi/sites\n/usr/sbin/rclone copy /tmp/sites.$TIMESTMP.tar.gz B2_UNIFI.CONTROLLER.NAME:BUCKETNAME\nrm sites.$TIMESTMP.tar.gz' | sudo tee -a /usr/local/bin/unifi_b2_backup.sh
sudo chmod +x /usr/local/bin/unifi_b2_backup.sh
# Schedule Cron Job to run unifi_b2_backup.sh every Sunday, After UniFi Controller Automated Backups
sudo crontab -l | { cat; echo "45 21 * * 0 /usr/local/bin/unifi_b2_backup.sh"; } | crontab -
