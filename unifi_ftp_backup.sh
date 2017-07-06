#!/bin/bash
  HOST='FTPSERVERFQDN' # server.domain.com
  USER='FTPUSERACCOUNT' # username
  PASSWD='PASSWORD' # P@ssw0rd
  TIMESTMP=$(date +'%Y%m%d_%H%M%S') # 20170706_114432
  
  # Create .tar.gz for upload
  cd /tmp
  tar -zcvf backup.$TIMESTMP.tar.gz /var/lib/unifi/backup
  tar -zcvf sites.$TIMESTMP.tar.gz /var/lib/unifi/sites
  
  # Connect to FTP Server
  ftp -n -v $HOST << EOT
  ascii
  user $USER $PASSWD
  prompt
  # Create target folder structure
  mkdir $(date +'%Y-%m-%d') # 2017-07-06
  # Perform Backup
  cd $(date +'%Y-%m-%d')
  lcd /tmp
  put backup.$TIMESTMP.tar.gz
  put sites.$TIMESTMP.tar.gz
  bye
  EOT
  
  # Local Cleanup
  rm backup.$TIMESTMP.tar.gz
  rm sites.$TIMESTMP.tar.gz
