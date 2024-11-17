#!/bin/bash

MARIADB_USER=myuser
MARIADB_PSWD=mypswd
MARIADB_DBMS=tpcds

pushd /tpcds/data/

## All tables except dbgen_version 
tables=(date_dim time_dim call_center catalog_page item promotion warehouse ship_mode inventory store reason income_band household_demographics customer_demographics customer_address customer web_page web_site store_sales store_returns catalog_sales catalog_returns web_sales web_returns dbgen_version)

# tables=(store_returns store_sales catalog_returns catalog_sales web_returns web_sales promotion inventory item warehouse ship_mode call_center catalog_page store reason web_page web_site customer customer_address household_demographics customer_demographics income_band time_dim date_dim dbgen_version)

## Load data of all tables
rm -f results.txt
for tname in "${tables[@]}"
do

mariadb -u$MARIADB_USER -p$MARIADB_PSWD -D$MARIADB_DBMS --local_infile=1 <<EOF
SET FOREIGN_KEY_CHECKS = 0;
truncate table $tname;
SET FOREIGN_KEY_CHECKS = 1;
EOF

done

popd
