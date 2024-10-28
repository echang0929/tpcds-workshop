####
alias missing: 
q02,q14,q23,q49

####
interval format: 
grep " days)" ./part-* | cut -d: -f1 | sort | uniq
./part-05.sql
./part-12.sql
./part-16.sql
./part-20.sql
./part-21.sql
./part-32.sql
./part-37.sql
./part-40.sql
./part-77.sql
./part-80.sql
./part-82.sql
./part-92.sql
./part-94.sql
./part-95.sql
./part-98.sql

####
grep "group by rollup" ./part-* | cut -d: -f1 | sort | uniq
./part-05.sql
./part-14.sql
./part-18.sql
./part-22.sql
./part-27.sql
./part-36.sql
./part-70.sql
./part-77.sql
./part-80.sql
./part-86.sql
./part-67.sql

####
grep "cast " ./part-* | cut -d: -f1 | sort | uniq
./part-21.sql
./part-40.sql

####
grep "sum " ./part-* | cut -d: -f1 | sort | uniq
./part-48.sql

####
grep "full outer join" ./part-* | cut -d: -f1 | sort | uniq
./part-51.sql
./part-97.sql


####
convert int to signed
./part-54.sql