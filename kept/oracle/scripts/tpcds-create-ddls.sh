#!/bin/bash

ORACLE_SID=ORCLPDB1
ORACLE_USER=demouser
ORACLE_PSWD=demopswd
SHARED_PATH=/home/oracle/tpcds/ddls

echo exit | sqlplus $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID @$SHARED_PATH/tpcds.sql
echo exit | sqlplus $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID @$SHARED_PATH/tpcds_ri.sql
echo exit | sqlplus $ORACLE_USER/$ORACLE_PSWD@$ORACLE_SID @$SHARED_PATH/tpcds_source.sql
