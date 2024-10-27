#!/bin/bash

ORACLE_SID=ORCLPDB1
ORACLE_USER=demouser
ORACLE_PSWD=demopswd

pushd ~/tpcds/queries/

## echo exit | sqlplus $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID @/home/oracle/shared/queries/query_0.sql > result_0.txt

rm -f results.txt
for i in $(ls part-*.sql);
do 
  echo "#### $i" | tee -a results.txt

  c_start_time=$(date +%s)
  s_start_time=$(TZ=UTC-8 date -d @$c_start_time +'%F %T %Z %z')

sqlplus -S $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID >> results.txt << EOF
SET PAGESIZE 20000 
SET NEWPAGE NONE
SET HEADING ON
SET UNDERLINE ON
SET COLSEP "|"
SET LINESIZE 20000
SET FEEDBACK ON 
SET TRIMS OFF
SET TAB OFF 
@$i
EOF

  ## echo exit | sqlplus $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID @$i >> results.txt
  c_end_time=$(date +%s)
  s_end_time=$(TZ=UTC-8 date -d @$c_end_time +'%F %T %Z %z')
  elapsed=$(( c_end_time - c_start_time ))

  echo "from $s_start_time - to $s_end_time - elapsed: $elapsed" | tee -a results.txt
  ##echo "#### $i - elapsed: $elapsed" | tee -a results.txt 
done

popd