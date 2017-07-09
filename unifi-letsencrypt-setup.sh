# Prerequisites
sudo mkdir /usr/local/bin
sudo apt-get install wget openssl
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
 
# Backup current keystore
sudo cp /var/lib/unifi/keystore /var/lib/unifi/keystore.backup
 
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
