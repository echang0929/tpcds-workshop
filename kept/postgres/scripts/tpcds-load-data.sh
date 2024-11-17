#!/bin/bash

POSTGRES_USER=postgres
POSTGRES_PSWD=postgres
POSTGRES_DBMS=tpcds

pushd /tpcds/data/

## All tables except dbgen_version 
tables=(date_dim time_dim call_center catalog_page item promotion warehouse ship_mode inventory store reason income_band household_demographics customer_demographics customer_address customer web_page web_site store_sales store_returns catalog_sales catalog_returns web_sales web_returns dbgen_version)

# tables=(store_returns store_sales catalog_returns catalog_sales web_returns web_sales promotion inventory item warehouse ship_mode call_center catalog_page store reason web_page web_site customer customer_address household_demographics customer_demographics income_band time_dim date_dim dbgen_version)

## Load data of all tables
rm -f results.txt
for tname in "${tables[@]}"
do
  echo "#### $tname" | tee -a results.txt
  sed 's/.$//' $tname.dat > /tmp/$tname.dat

  c_start_time=$(date +%s)
  s_start_time=$(TZ=UTC-8 date -d @$c_start_time +'%F %T %Z %z')

  PASSWORD=$POSTGRES_PSWD psql -U $POSTGRES_USER $POSTGRES_DBMS -c \
    "COPY $tname FROM '/tmp/$tname.dat' (FORMAT CSV, DELIMITER '|', NULL '', ENCODING 'LATIN1')"

  c_end_time=$(date +%s)
  s_end_time=$(TZ=UTC-8 date -d @$c_end_time +'%F %T %Z %z')
  elapsed=$(( c_end_time - c_start_time ))

  rm -f /tmp/$tname.dat 
  echo "from $s_start_time - to $s_end_time - elapsed: $elapsed" | tee -a results.txt
done

PASSWORD=$POSTGRES_PSWD psql -U $POSTGRES_USER $POSTGRES_DBMS -c "ANALYZE VERBOSE"

popd
