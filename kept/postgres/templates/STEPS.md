
su postgres
createdb tpcds
psql tpcds -f tpcds.sql
psql tpcds -f tpcds_ri.sql

cd data/
tables=(date_dim time_dim call_center catalog_page item promotion warehouse ship_mode inventory store reason income_band household_demographics customer_demographics customer_address customer web_page web_site store_sales store_returns catalog_sales catalog_returns web_sales web_returns dbgen_version)

rm loadings.txt
for i in "${tables[@]}"
do
  echo "#### table $i" | tee -a loadings.txt

  sed 's/||/|\\N|/g' $i.dat  | sed 's/^|/\\N|/' | sed 's/|$//' > /tmp/$i.dat
  start_time=$(date +%s)
  psql tpcds -c "\\copy $i FROM '/tmp/$i.dat' CSV DELIMITER '|' NULL '\N' ENCODING 'LATIN1'"
  elapsed=$(( $(date +%s) - $start_time ))

  echo "from $(TZ=UTC-8 date -d @$start_time +'%F %T %Z %z') - to $(TZ=UTC-8 date -d @$end_time +'%F %T %Z %z') - elapsed: $elapsed" | tee -a loadings.txt
done

for i in "${tables[@]}"
do
  echo "#### table $i"
  psql tpcds -c "truncate table $i cascade;"
done


for i in "${tables[@]}"
do
  echo "#### table $i"
  psql tpcds -c "select count(*) from $i;"
done


##---------------

psql tpcds -c "ANALYZE VERBOSE"
psql tpcds < ./queries/query_0.sql > result0.txt

## https://dba.stackexchange.com/questions/220933/query-for-all-the-postgres-configuration-parameters-current-values
rm results.txt
for i in $(ls part-*.sql);
do 
  echo "#### $i" | tee -a results.txt

  start_time=$(date +%s)
  psql tpcds < $i >> results.txt
  end_time=$(date +%s)
  elapsed=$(( end_time - start_time ))

  echo "from $(TZ=UTC-8 date -d @$start_time +'%F %T %Z %z') - to $(TZ=UTC-8 date -d @$end_time +'%F %T %Z %z') - elapsed: $elapsed" | tee -a results.txt
done


###############

SELECT * FROM pg_stat_activity WHERE state = 'active';
SELECT pg_cancel_backend(PID);
SELECT pg_terminate_backend(PID);
