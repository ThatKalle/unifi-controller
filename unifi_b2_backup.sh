#!/bin/bash
cd /tmp
# Backup /var/lib/unifi/backup
TIMESTMP=$(date +'%Y%m%d_%H%M%S')
tar -zcvf backup.$TIMESTMP.tar.gz /var/lib/unifi/backup
/usr/sbin/rclone copy /tmp/backup.$TIMESTMP.tar.gz B2_UNIFI.CONTROLLER.NAME:BUCKETNAME-unifi
rm backup.$TIMESTMP.tar.gz

# Backup /var/lib/unifi/sites
TIMESTMP=$(date +'%Y%m%d_%H%M%S')
tar -zcvf sites.$TIMESTMP.tar.gz /var/lib/unifi/sites
/usr/sbin/rclone copy /tmp/sites.$TIMESTMP.tar.gz B2_UNIFI.CONTROLLER.NAME:BUCKETNAME-unifi
rm sites.$TIMESTMP.tar.gz

# Remote Cleanup
# Only run Cleanup if there are data present in bucket newer than 6 weeks == previous backups successful
if [[ $(/usr/sbin/rclone ls B2_UNIFI.CONTROLLER.NAME:BUCKETNAME-unifi --max-age 6w) ]]; then
# Delete everything older than 6 weeks
/usr/sbin/rclone delete B2_UNIFI.CONTROLLER.NAME:BUCKETNAME-unifi --min-age 6w
/usr/sbin/rclone cleanup B2_UNIFI.CONTROLLER.NAME:BUCKETNAME-unifi --min-age 8w
fi
