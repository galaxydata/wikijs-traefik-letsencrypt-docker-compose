#!/bin/bash

WIKIJS_CONTAINER=$(docker ps -aqf "name=wikijs")
WIKIJS_BACKUPS_CONTAINER=$(docker ps -aqf "name=wikijs_backups")

echo "--> All available database backups:"

for entry in $(docker container exec -it $WIKIJS_BACKUPS_CONTAINER sh -c "ls /srv/wikijs-postgres/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore database and press [ENTER]
--> Example: wikijs-postgres-backup-YYYY-MM-DD_hh-mm.gz"
echo -n "--> "

read SELECTED_DATABASE_BACKUP

echo "--> $SELECTED_DATABASE_BACKUP was selected"

echo "--> Stopping service..."
docker stop $WIKIJS_CONTAINER

echo "--> Restoring database..."
docker exec -it $WIKIJS_BACKUPS_CONTAINER sh -c 'PGPASSWORD="$(echo $POSTGRES_PASSWORD)" dropdb -h postgres -p 5432 wikijs -U wikijsdbuser \
&& PGPASSWORD="$(echo $POSTGRES_PASSWORD)" createdb -h postgres -p 5432 wikijsdb -U wikijsdbuser \
&& PGPASSWORD="$(echo $POSTGRES_PASSWORD)" gunzip -c /srv/wikijs-postgres/backups/'$SELECTED_DATABASE_BACKUP' | PGPASSWORD=$(echo $POSTGRES_PASSWORD) psql -h postgres -p 5432 wikijsdb -U wikijsdbuser'
echo "--> Database recovery completed..."

echo "--> Starting service..."
docker start $WIKIJS_CONTAINER