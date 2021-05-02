#!/usr/bin/env bash

## source environmient variables for later use
source /home/ubuntu/deployments/secrets/prod-secrets.sh

BACKUPS_DIR=/home/ubuntu/backups


## Change directory to backups dir
cd $BACKUPS_DIR

backup_name=website-`date +%Y-%m-%d"_"%H_%M_%S`
docker exec -t website_db_1 mysqldump $WORDPRESS_DB_NAME -u $WORDPRESS_DB_USER --password=$WORDPRESS_DB_PASSWORD > $BACKUPS_DIR/$backup_name.sql
tar -czvf $BACKUPS_DIR/$backup_name.tar.gz $backup_name.sql

## Remove raw SQL backups
rm -v ./*.sql

## Configure file backup with rclone
rclone copy --immutable /var/lib/docker/volumes/website_wordpress/_data/wp-content/uploads yayoflautas_madrid:wp-content/uploads
rclone copy --immutable $BACKUPS_DIR yayoflautas_madrid:database

## Cleanup after backups
rm -v ./*.tar.gz
