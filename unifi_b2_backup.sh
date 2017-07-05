#!/bin/bash
cd /tmp
# Backup /var/lib/unifi/backup
TIMESTMP=$(date +'%Y%m%d_%H%M%S')
tar -zcvf backup.$TIMESTMP.tar.gz /var/lib/unifi/backup
/usr/sbin/rclone copy /tmp/backup.$TIMESTMP.tar.gz B2_UNIFI.CONTROLLER.NAME:BUCKETNAME
rm backup.$TIMESTMP.tar.gz

# Backup /var/lib/unifi/sites
TIMESTMP=$(date +'%Y%m%d_%H%M%S')
tar -zcvf sites.$TIMESTMP.tar.gz /var/lib/unifi/sites
/usr/sbin/rclone copy /tmp/sites.$TIMESTMP.tar.gz B2_UNIFI.CONTROLLER.NAME:BUCKETNAME
rm sites.$TIMESTMP.tar.gz
