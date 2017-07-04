#!/bin/bash
# Get the certificate from LetsEncrypt
/usr/local/bin/certbot-auto renew --quiet --no-self-upgrade
# Convert cert to PKCS #12 format
/usr/bin/openssl pkcs12 -export -inkey /etc/letsencrypt/live/UNIFI.CONTROLLER.NAME/privkey.pem -in /etc/letsencrypt/live/UNIFI.CONTROLLER.NAME/fullchain.pem -out /usr/local/bin/lecert.p12 -name ubnt -password pass:PASSWORD
# Load it into the java keystore that UBNT understands
/usr/bin/keytool -importkeystore -deststorepass aircontrolenterprise -destkeypass aircontrolenterprise -destkeystore /var/lib/unifi/keystore -srckeystore /usr/local/bin/lecert.p12 -srcstoretype PKCS12 -srcstorepass PASSWORD -alias ubnt -noprompt
# Clean up and use new cert
rm /usr/local/bin/lecert.p12
/etc/init.d/unifi restart
