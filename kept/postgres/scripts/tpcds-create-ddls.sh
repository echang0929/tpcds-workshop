#!/bin/bash

POSTGRES_USER=postgres
POSTGRES_PSWD=postgres
POSTGRES_DBMS=tpcds

## psql postgresql://$POSTGRES_USER:$POSTGRES_PSWD@localhost/$POSTGRES_DBMS
PASSWORD=$POSTGRES_PSWD psql -U $POSTGRES_USER $POSTGRES_DBMS -f /tpcds/ddls/tpcds.sql
PASSWORD=$POSTGRES_PSWD psql -U $POSTGRES_USER $POSTGRES_DBMS -f /tpcds/ddls/tpcds_ri.sql
PASSWORD=$POSTGRES_PSWD psql -U $POSTGRES_USER $POSTGRES_DBMS -f /tpcds/ddls/tpcds_source.sql
