#!/bin/bash

ORACLE_SID=ORCLPDB1
ORACLE_USER=demouser
ORACLE_PSWD=demopswd

pushd ~/tpcds/data/

## All tables except dbgen_version 
tables=(date_dim time_dim call_center catalog_page item promotion warehouse ship_mode inventory store reason income_band household_demographics customer_demographics customer_address customer web_page web_site store_sales store_returns catalog_sales catalog_returns web_sales web_returns dbgen_version)

# tables=(store_returns store_sales catalog_returns catalog_sales web_returns web_sales promotion inventory item warehouse ship_mode call_center catalog_page store reason web_page web_site customer customer_address household_demographics customer_demographics income_band time_dim date_dim dbgen_version)


## Disable constraints of foreign keys for tables
for tname in "${tables[@]}"
do 
constraints=($(sqlplus -S $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID << EOF
SET HEADING OFF
SET SERVEROUTPUT ON
SET LINESIZE 20000
SET FEEDBACK OFF
SET TRIMS ON 
SELECT LISTAGG(CONSTRAINT_NAME, ' ')
FROM ALL_CONSTRAINTS
WHERE TABLE_NAME=UPPER('$tname') AND CONSTRAINT_TYPE='R'
GROUP BY TABLE_NAME
;
EOF
) )

for cname in "${constraints[@]}"
do 
result=$(sqlplus -S $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID << EOF
ALTER TABLE $tname DISABLE CONSTRAINT $cname;
EOF
)

done
done


## Load data of all tables
rm -f results.txt
for tname in "${tables[@]}"
do 

### Generate all columns for a table
if [ "$tname" = "dbgen_version" ]; then 
columns=$(cat << EOF 
DV_VERSION ,
X_DATE     BOUNDFILLER,
X_TIME     BOUNDFILLER,
DV_CREATE_DATE  EXPRESSION "TO_DATE(:X_DATE || ' ' || :X_TIME, 'YYYY-MM-DD HH24.MI.SS')",
DV_CMDLINE_ARGS,
ZZ FILLER
EOF
)
else 
columns=$(sqlplus -S $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID << EOF
SET HEADING OFF
SET SERVEROUTPUT ON
SET LINESIZE 20000
SET FEEDBACK OFF
SET TRIMS ON 
SELECT LISTAGG(
        CASE WHEN DATA_TYPE='DATE' 
            THEN COLUMN_NAME||' DATE' 
            ELSE COLUMN_NAME 
        END,',') WITHIN GROUP (ORDER BY COLUMN_ID) || ',ZZ FILLER'
FROM USER_TAB_COLUMNS 
WHERE TABLE_NAME=UPPER('$tname') 
GROUP BY TABLE_NAME 
;
EOF
)
fi 

### Create control.ctl file
cat <<EOF > control.ctl
OPTIONS (SILENT=(ALL) )
LOAD DATA
INFILE $tname.dat 
INSERT
INTO TABLE $tname TRUNCATE
FIELDS TERMINATED BY "|"
DATE FORMAT "YYYY-MM-DD"
TRAILING NULLCOLS
($columns)
EOF

### Load data file
  echo "#### $tname" | tee -a results.txt

  c_start_time=$(date +%s)
  s_start_time=$(TZ=UTC-8 date -d @$c_start_time +'%F %T %Z %z')

sqlldr $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID control=control.ctl | tee -a results.txt
rm control.ctl

  c_end_time=$(date +%s)
  s_end_time=$(TZ=UTC-8 date -d @$c_end_time +'%F %T %Z %z')
  elapsed=$(( c_end_time - c_start_time ))

  echo "from $s_start_time - to $s_end_time - elapsed: $elapsed" | tee -a results.txt

done


## Enable all constraints for foreign keys
for tname in "${tables[@]}"
do 
constraints=($(sqlplus -S $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID << EOF
SET HEADING OFF
SET SERVEROUTPUT ON
SET LINESIZE 20000
SET FEEDBACK OFF
SET TRIMS ON 
SELECT LISTAGG(CONSTRAINT_NAME, ' ')
FROM ALL_CONSTRAINTS
WHERE TABLE_NAME=UPPER('$tname') AND CONSTRAINT_TYPE='R'
GROUP BY TABLE_NAME
;
EOF
) )

for cname in "${constraints[@]}"
do 
result=$(sqlplus -S $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID << EOF
ALTER TABLE $tname ENABLE CONSTRAINT $cname;
EOF
)

done 
done 

popd
