#!/bin/bash

POSTGRES_USER=postgres
POSTGRES_PSWD=postgres
POSTGRES_DBMS=tpcds

pushd /tpcds/queries/

PASSWORD=$POSTGRES_PSWD psql -U $POSTGRES_USER $POSTGRES_DBMS -c "ANALYZE VERBOSE"

rm -f results.txt
for i in $(ls part-*.sql);
do
  if [ $i == "part-04.sql" ]; then continue; fi 
  if [ $i == "part-11.sql" ]; then continue; fi 

  echo "#### $i" | tee -a results.txt

  c_start_time=$(date +%s)
  s_start_time=$(TZ=UTC-8 date -d @$c_start_time +'%F %T %Z %z')

  PASSWORD=$POSTGRES_PSWD psql -U $POSTGRES_USER $POSTGRES_DBMS < $i >> results.txt

  c_end_time=$(date +%s)
  s_end_time=$(TZ=UTC-8 date -d @$c_end_time +'%F %T %Z %z')
  elapsed=$(( c_end_time - c_start_time ))

  echo "from $s_start_time - to $s_end_time - elapsed: $elapsed" | tee -a results.txt
  ##echo "#### $i - elapsed: $elapsed" | tee -a results.txt 
done

popd