#!/bin/bash

MYSQL_USER=myuser
MYSQL_PSWD=mypswd
MYSQL_DBMS=tpcds

pushd /tpcds/data/

## All tables except dbgen_version 
tables=(date_dim time_dim call_center catalog_page item promotion warehouse ship_mode inventory store reason income_band household_demographics customer_demographics customer_address customer web_page web_site store_sales store_returns catalog_sales catalog_returns web_sales web_returns dbgen_version)

# tables=(store_returns store_sales catalog_returns catalog_sales web_returns web_sales promotion inventory item warehouse ship_mode call_center catalog_page store reason web_page web_site customer customer_address household_demographics customer_demographics income_band time_dim date_dim dbgen_version)

## Load data of all tables
rm -f results.txt
for tname in "${tables[@]}"
do
  echo "#### $tname" | tee -a results.txt

mysql -u$MYSQL_USER -p$MYSQL_PSWD -D$MYSQL_DBMS --local_infile=1 <<EOF
SET FOREIGN_KEY_CHECKS = 0;
truncate table $tname;
SET FOREIGN_KEY_CHECKS = 1;
EOF

  echo "from $s_start_time - to $s_end_time - elapsed: $elapsed" | tee -a results.txt
done

popd
