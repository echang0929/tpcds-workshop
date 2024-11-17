#!/bin/bash

MARIADB_USER=myuser
MARIADB_PSWD=mypswd
MARIADB_DBMS=tpcds

pushd /tpcds/queries/

rm -f results.txt
for i in $(ls part-*.sql);
do 
  if [ $i == "part-95.sql" ]; then continue; fi 

  echo "#### $i" | tee -a results.txt

  c_start_time=$(date +%s)
  s_start_time=$(TZ=UTC-8 date -d @$c_start_time +'%F %T %Z %z')

mariadb -u$MARIADB_USER -p$MARIADB_PSWD -D$MARIADB_DBMS < $i >> results.txt

  c_end_time=$(date +%s)
  s_end_time=$(TZ=UTC-8 date -d @$c_end_time +'%F %T %Z %z')
  elapsed=$(( c_end_time - c_start_time ))

  echo "from $s_start_time - to $s_end_time - elapsed: $elapsed" | tee -a results.txt
  ##echo "#### $i - elapsed: $elapsed" | tee -a results.txt 
done

popd