#!/bin/bash
num_iterations=5
db_name='demo'
db_name2='test2'
log_file='output.log'
path_to_backup='/var/lib/pgsql/test'
echo "BEGIN"
dropdb -U postgres --if-exist $db_name2

echo `date`
rm -rf /var/lib/pgsql/test/*

for (( i=1; i <= $num_iterations; i++ ))
do
	/root/clear.sh
	s1="plain dump"
	echo $s1"-"$i
	st=`date +"%s%3N"`
	pg_dump -d $db_name -U postgres > $path_to_backup/$db_name.sql
	s2=$((`date +"%s%3N"` - $st))
	s3=`du -sh $path_to_backup|awk '{print $1}'`
	createdb -U postgres $db_name2
	st=`date +"%s%3N"`
	psql -d $db_name2 -U postgres -q < $path_to_backup/$db_name.sql
	s4=$((`date +"%s%3N"` - $st))
	dropdb -U postgres $db_name2
	echo $s1 "out" $s2 "size "$s3 "in" $s4 >>$log_file
done

echo "========================"
for (( j=6; j >=2; j=j-2 ))
do
	for (( i=1; i <= $num_iterations; i++ ))
	do
		s1="plain dump gzip="$j
		echo $s1"-"$i
		/root/clear.sh
		st=`date +"%s%3N"`
		pg_dump -d $db_name -U postgres | gzip -$j > $path_to_backup/$db_name.sql.gz
		s2=$((`date +"%s%3N"` - $st))
		s3=`du -sh $path_to_backup|awk '{print $1}'`

		createdb -U postgres $db_name2

		st=`date +"%s%3N"`
		gunzip < $path_to_backup/$db_name.sql.gz |psql -d $db_name2 -U postgres -q
		s4=$((`date +"%s%3N"` - $st))
		
		dropdb -U postgres $db_name2
		echo $s1 "out" $s2 "size "$s3 "in" $s4 >>$log_file
	done
done
echo "========================"
for (( j=6; j >=2; j=j-2 ))
do
	for (( i=1; i <= $num_iterations; i++ ))
	do
		s1="plain dump pigz="$j
		echo $s1"-"$i
		/root/clear.sh
		st=`date +"%s%3N"`
		pg_dump -d $db_name -U postgres | pigz -$j > $path_to_backup/$db_name.sql.gz
		s2=$((`date +"%s%3N"` - $st))
		s3=`du -sh $path_to_backup|awk '{print $1}'`

		createdb -U postgres $db_name2

		st=`date +"%s%3N"`
		pigz -d < $path_to_backup/$db_name.sql.gz |psql -d $db_name2 -U postgres -q
		s4=$((`date +"%s%3N"` - $st))
		
		dropdb -U postgres $db_name2
		echo $s1 "out" $s2 "size "$s3 "in" $s4 >>$log_file
	done
done

echo "========================"
for (( i=1; i <= $num_iterations; i++ ))
do
	s1="custom dump"
	echo $s1"-"$i
	/root/clear.sh
	rm -rf /var/lib/pgsql/test/*
	st=`date +"%s%3N"`
	pg_dump -Fc -d $db_name -U postgres -f $path_to_backup/$db_name.dmp
	s2=$((`date +"%s%3N"` - $st))
	s3=`du -sh $path_to_backup|awk '{print $1}'`

	createdb -U postgres $db_name2
	st=`date +"%s%3N"`
	pg_restore -U postgres -d $db_name2 $path_to_backup/$db_name.dmp
	s4=$((`date +"%s%3N"` - $st))
	
	dropdb -U postgres $db_name2
	echo $s1 "out" $s2 "size "$s3 "in" $s4 >>$log_file
done

echo "========================"
for (( z=6; z >=2; z=z-2 ))
do
	for (( i=1; i <= $num_iterations; i++ ))
	do
		s1="custom dump Z="$z
		echo $s1"-"$i
		/root/clear.sh
		st=`date +"%s%3N"`
		pg_dump -Fc -Z$z -d $db_name -U postgres -f $path_to_backup/$db_name.dmp
		s2=$((`date +"%s%3N"` - $st))
		s3=`du -sh $path_to_backup|awk '{print $1}'`

		createdb -U postgres $db_name2
		st=`date +"%s%3N"`
		pg_restore -U postgres -j$z -d $db_name2 $path_to_backup/$db_name.dmp
		s4=$((`date +"%s%3N"` - $st))
		
		dropdb -U postgres $db_name2
		echo $s1 "out" $s2 "size "$s3 "in" $s4 >>$log_file
	done
done


echo "========================"
for (( j=6; j >=2; j=j-2 ))
do
	for (( i=1; i <= $num_iterations; i++ ))
	do
		s1="custom dump Z0 pigz="$j
		echo $s1"-"$i
		/root/clear.sh
		st=`date +"%s%3N"`
		pg_dump -Fc -Z0 -d $db_name -U postgres |pigz -$j> $path_to_backup/$db_name.dmp.gz
		s2=$((`date +"%s%3N"` - $st))
		s3=`du -sh $path_to_backup|awk '{print $1}'`
		createdb -U postgres $db_name2
		st=`date +"%s%3N"`
		pigz -d $path_to_backup/$db_name.dmp.gz
		pg_restore -U postgres -j$j -d $db_name2 $path_to_backup/$db_name.dmp
		s4=$((`date +"%s%3N"` - $st))
		
		dropdb -U postgres $db_name2
		echo $s1 "out" $s2 "size "$s3 "in" $s4 >>$log_file
	done
done


echo "========================"
for (( i=1; i <= $num_iterations; i++ ))
do
	s1="directory dump"
	echo $s1"-"$i
	/root/clear.sh
	st=`date +"%s%3N"`
	pg_dump -Fd -d $db_name -U postgres -f $path_to_backup/$db_name
	s2=$((`date +"%s%3N"` - $st))
	s3=`du -sh $path_to_backup|awk '{print $1}'`


	createdb -U postgres $db_name2
	st=`date +"%s%3N"`
	pg_restore -U postgres -d $db_name2 $path_to_backup/$db_name
	s4=$((`date +"%s%3N"` - $st))
	
	dropdb -U postgres $db_name2
	echo $s1 "out" $s2 "size "$s3 "in" $s4 >>$log_file
done

echo "========================"
for (( j=2; j <=8; j=j+2 ))
do
	for (( i=1; i <= $num_iterations; i++ ))
	do
		s1="directory dump -Z0 j="$j
		echo $s1"-"$i
		/root/clear.sh
		st=`date +"%s%3N"`
		pg_dump -Fd -Z0 -j$j -d $db_name -U postgres -f $path_to_backup/$db_name
		s2=$((`date +"%s%3N"` - $st))
	   	s3=`du -sh $path_to_backup|awk '{print $1}'`

		createdb -U postgres $db_name2
		st=`date +"%s%3N"`
		pg_restore -U postgres -d $db_name2 -j$j $path_to_backup/$db_name
		s4=$((`date +"%s%3N"` - $st))
		
		dropdb -U postgres $db_name2
		echo $s1 "out" $s2 "size "$s3 "in" $s4 >>$log_file

	done
done

echo "========================"
for (( z=6; z>=2; z=z-2 ))
do
	for (( j=2; j<=8; j=j+2 ))
	do
		for (( i=1; i <= $num_iterations; i++ ))
		do
			s1="directory dump Z$z j=$j"
			echo $s1"-"$i
			/root/clear.sh
			st=`date +"%s%3N"`
			pg_dump -Fd -Z$z -j$j -d $db_name -U postgres -f $path_to_backup/$db_name
			s2=$((`date +"%s%3N"` - $st))
			s3=`du -sh $path_to_backup|awk '{print $1}'`

			createdb -U postgres $db_name2
			st=`date +"%s%3N"`
			pg_restore -U postgres -d $db_name2 -j$j $path_to_backup/$db_name
			s4=$((`date +"%s%3N"` - $st))
			
			dropdb -U postgres $db_name2
			echo $s1 "out" $s2 "size "$s3 "in" $s4 >>$log_file
		done
	done
done
echo "END"
