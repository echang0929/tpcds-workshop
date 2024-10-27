#!/bin/bash

ORACLE_SID=ORCLPDB1
ORACLE_USER=demouser
ORACLE_PSWD=demopswd

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


## truncate all tables
for tname in "${tables[@]}"
do 

sqlplus -S $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID << EOF
truncate table $tname;
EOF

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
