#!/bin/sh
LOG=~/ex.log
export LOG
date >>$LOG
# restart PostgreSQL
systemctl stop postgresql-13
#ps -ef|grep bin/postgres|grep -v grep
#echo 'Restarting PostgreSQL'
systemctl start postgresql-13
#status of PostgreSQL
#ps –ef|grep bin/postgres|grep –v grep
free –m>>$LOG
sync; echo 3 > /proc/sys/vm/drop_caches
free –m>>$LOG
rm -rf /var/lib/pgsql/test/*
echo ‘================================================‘>>$LOG
#add simple comment
