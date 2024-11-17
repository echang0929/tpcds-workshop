#!/bin/bash

MARIADB_USER=myuser
MARIADB_PSWD=mypswd
MARIADB_DBMS=tpcds

mariadb -u$MARIADB_USER -p$MARIADB_PSWD -D$MARIADB_DBMS < /tpcds/ddls/tpcds.sql
mariadb -u$MARIADB_USER -p$MARIADB_PSWD -D$MARIADB_DBMS < /tpcds/ddls/tpcds_ri.sql
mariadb -u$MARIADB_USER -p$MARIADB_PSWD -D$MARIADB_DBMS < /tpcds/ddls/tpcds_source.sql
