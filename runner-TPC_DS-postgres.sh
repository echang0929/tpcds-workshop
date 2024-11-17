#==============================================================
## Start TPC-DS working
cd tpcds-workshop
mkdir files shared 
#~~~~~ Download TPC-DS package: https://www.tpc.org/tpc_documents_current_versions/current_specifications5.asp
cp ~/Downloads/5DAA63D1-0F8F-4FC3-9A66-8F18899EF1B5-TPC-DS-Tool.zip ./files/

docker compose -f docker-compose-tpcds-postgres.yml up -d --wait

#--------------------------------------------------------------
### Work in workdesk(ubuntu) container 
docker exec -it workdesk bash

apt-get update -y && apt-get upgrade -y
apt-get install gcc make flex bison byacc unzip -y

#### Handle TPC-DS package
cd works/
unzip 5DAA63D1-0F8F-4FC3-9A66-8F18899EF1B5-TPC-DS-Tool.zip

cd DSGen-software-code-3.2.0rc1/tools/
make clean
make OS=LINUX all

#### Generate TPC-DS data
mkdir -p /shared/data/
./dsdgen -SCALE 1 -DIR /shared/data/ 

#### Copy template files to postgres dedicated folder
## mkdir -p /kept/postgres/templates
## cp ../query_templates/* /kept/postgres/templates/
#### and Adjust it 

#### Generate and split TPC-DS queries
mkdir -p /shared/postgres/queries/
./dsqgen -OUTPUT_DIR /shared/postgres/queries \
  -DIRECTORY /kept/postgres/templates \
  -INPUT /kept/postgres/templates/templates.lst \
  -VERBOSE Y -QUALIFY Y -DIALECT postgres 

pushd /shared/postgres/queries
awk '
  /^-- start/{
    ++part; 
    output_file=sprintf("part-%02d.sql", part);
  }
  {print >> output_file;}
' ./query_0.sql
popd

#### Copy DDL SQLs to shared folder
## mkdir -p /kept/postgres/ddls/
## cp *.sql /kept/postgres/ddls/
#### and Adjust it

exit

#--------------------------------------------------------------
### Work in database(PostgreSQL) container 
docker exec -it postgres bash

#~~~~~ Adjust the following ddl sqls for correct creatation 
scripts/tpcds-create-ddls.sh

scripts/tpcds-load-data.sh

#~~~~~ Adjust the following query sqls for correct running
scripts/tpcds-run-queries.sh

exit 