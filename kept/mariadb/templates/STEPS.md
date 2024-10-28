
cd works/
mysql --password=password -e "create database tpcds"
mysql --password=password -Dtpcds < tpcds.sql
mysql --password=password -Dtpcds < tpcds_ri.sql
mysql --password=password -Dtpcds -e "show tables"


###==============
cd data/
tables=(date_dim time_dim call_center catalog_page item promotion warehouse ship_mode inventory store reason income_band household_demographics customer_demographics customer_address customer web_page web_site store_sales store_returns catalog_sales catalog_returns web_sales web_returns dbgen_version)

rm loadings.txt
for i in "${tables[@]}"
do
  echo "#### table $i" | tee -a loadings.txt

  sed 's/||/|\\N|/g' $i.dat  | sed 's/^|/\\N|/' | sed 's/|$//' > /tmp/$i.dat
  start_time=$(date +%s)
  mysql --password=password -Dtpcds -e \
    "load data local infile '/tmp/$i.dat' replace into table $i character set latin1 fields terminated by '|'"
  end_time=$(date +%s)
  elapsed=$(( end_time - start_time ))

  echo "from $(TZ=UTC-8 date -d @$start_time +'%F %T %Z %z') - to $(TZ=UTC-8 date -d @$end_time +'%F %T %Z %z') - elapsed: $elapsed" | tee -a loadings.txt
done



###=================
mysql --password=password -Dtpcds -e "create index idx_ws_speedy on web_sales(ws_order_number);"

cd queries/
mysql --password=password -Dtpcds < query_0.sql > result0.txt

rm results.txt
for i in $(ls part-*.sql);
do 
  echo "#### $i" | tee -a results.txt

  start_time=$(date +%s)
  mysql --password=password -Dtpcds < $i >> results.txt
  end_time=$(date +%s)
  elapsed=$(( end_time - start_time ))

  echo "from $(TZ=UTC-8 date -d @$start_time +'%F %T %Z %z') - to $(TZ=UTC-8 date -d @$end_time +'%F %T %Z %z') - elapsed: $elapsed" | tee -a results.txt
done


