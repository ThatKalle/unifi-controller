##
# Place a .pfx version of your certificate in ./tmp -- /tmp/certificate.pfx
# Password in this example: C3rtificate3xportP@ssword
##

# Navigate to UniFi install folder
cd /var/lib/unifi/

# .pfx information
sudo keytool -list -keystore /tmp/certificate.pfx -storetype pkcs12
# Provide the password used when exporting the certificate.
 C3rtificate3xportP@ssword
# Note the Alias shown
# eg. le-d88c06cd-7919-04f4-bfd1-51eebd0ea8ba

# Backup UniFi keystore to /var/lib/unifi/keystore.orig
sudo mv /var/lib/unifi/keystore /var/lib/unifi/keystore.orig

# Create a new keystore
sudo keytool -importkeystore -srcstoretype pkcs12 -srcalias le-d88c06cd-7919-04f4-bfd1-51eebd0ea8ba -srckeystore /tmp/certificate.pfx -keystore keystore -destalias unifi
# use -srcalias from above
# use -srckeystore from above
 # Password to open .pfx
 C3rtificate3xportP@ssword
 # Set password to open keystore
 aircontrolenterprise
 aircontrolenterprise
# Restart UniFi service for changes to take effect
sudo service unifi restart
