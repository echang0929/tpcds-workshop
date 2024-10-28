#!/bin/bash

MYSQL_USER=myuser
MYSQL_PSWD=mypswd
MYSQL_DBMS=tpcds

pushd /tpcds/queries/

rm -f results.txt
for i in $(ls part-*.sql);
do 
  echo "#### $i" | tee -a results.txt

  c_start_time=$(date +%s)
  s_start_time=$(TZ=UTC-8 date -d @$c_start_time +'%F %T %Z %z')

  mysql -u$MYSQL_USER -p$MYSQL_PSWD -D$MYSQL_DBMS < $i >> results.txt

  c_end_time=$(date +%s)
  s_end_time=$(TZ=UTC-8 date -d @$c_end_time +'%F %T %Z %z')
  elapsed=$(( c_end_time - c_start_time ))

  echo "from $s_start_time - to $s_end_time - elapsed: $elapsed" | tee -a results.txt
  ##echo "#### $i - elapsed: $elapsed" | tee -a results.txt 
done

popd