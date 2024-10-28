#!/bin/bash

MYSQL_USER=myuser
MYSQL_PSWD=mypswd
MYSQL_DBMS=tpcds

mysql -u$MYSQL_USER -p$MYSQL_PSWD -D$MYSQL_DBMS < /tpcds/ddls/tpcds.sql
mysql -u$MYSQL_USER -p$MYSQL_PSWD -D$MYSQL_DBMS < /tpcds/ddls/tpcds_ri.sql
mysql -u$MYSQL_USER -p$MYSQL_PSWD -D$MYSQL_DBMS < /tpcds/ddls/tpcds_source.sql
