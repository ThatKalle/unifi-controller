# UniFi Controller
A collection of Scripts and command references to be used with UniFi Controller running on Linux.

### unifi-controller-install.sh
Complete installation of UniFi Controller on Ubuntu including Firewall, Fail2Ban, automated Let's Encrypt and Backups.
```
sudo service unifi status
sudo service fail2ban status
sudo service longview status
sudo fail2ban-client status ubiquiti
sudo fail2ban-client set ubiquiti unbanip XXX.XXX.XXX.XXX
sudo fail2ban-client status sshd
```

## Let's Encrypt
### unifi-letsencrypt-setup.sh
Installation and configuration of automated Let's Encrypt using certbot and cronjob.
* Please read the [related post](https://kallelilja.com/2017/07/automated-lets-encrypt-unifi-controller/) for more information.

### renew_lets_encrypt_cert.sh
Cronjob task for automated Let's Encrypt

## Backup
### unifi-b2-setup.sh
Installation and configuration of automated off-site backups to Backblaze B2.
* Please read the [related post](https://kallelilja.com/2017/07/backup-unifi-controller-backblaze-b2/) for more information.

### unifi_b2_backup.sh
Cronjob task for automated Backups to Backblaze B2 - B2_UNIFI.CONTROLLER.NAME:BUCKETNAME

### unifi_ftp_backup.sh
Cronjob task for automated Backups to FTP server
