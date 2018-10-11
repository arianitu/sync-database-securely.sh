#!/bin/bash

ENV=${1:-user@host}

echo "Deploying to $ENV"
echo "Backing up database first"
PGPASSWORD=*** pg_dumpall > backup-$(date "+%b-%d-%Y-%H-%M-%S").sql
echo "Done backing up"

echo "Opening an SSH tunnel to $ENV"
ssh -M -S psql-ctrl-socket -fnNT -L 127.0.0.1:3333:localhost:5432 $ENV
ssh -S psql-ctrl-socket -O check $ENV

echo "Restoring database from localhost to remote $ENV"

# Optionally wipe the remote tables, uncomment below.
#
#echo "Deleting existing tables on remote $ENV"
#PGPASSWORD=*** psql -h localhost -p 3333 -U USER DATABASE -c "drop owned by USER"

echo "Restoring"
PGPASSWORD=*** pg_dump -h localhost -U USER DATABASE | PGPASSWORD=*** psql -h localhost -p 3333 -U USER DATABASE

echo "Closing SSH tunnel"
ssh -S psql-ctrl-socket -O exit $ENV
