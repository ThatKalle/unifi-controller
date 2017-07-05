# UniFi Controller
A collection of Scripts and command references to be used with UniFi Controller running on Linux.

### unifi-controller-install.sh
Complete installation of UniFi Controller on Ubuntu including Firewall, Fail2Ban, automated Let's Encrypt and Backups.

## Let's Encrypt
### unifi-letsencrypt-setup.sh
Installation and configuration of automated Let's Encrypt using certbot and cronjob.

## renew_lets_encrypt_cert.sh
Cronjob task for automated Let's Encrypt

## Backup
### unifi_b2_backup.sh
Cronjob task for automated Backups to Backblaze B2 - B2_UNIFI.CONTROLLER.NAME:BUCKETNAME
