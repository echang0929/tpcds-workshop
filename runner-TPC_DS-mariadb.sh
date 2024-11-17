#==============================================================
## Start TPC-DS working
cd tpcds-workshop
mkdir files shared 
#~~~~~ Download TPC-DS package: https://www.tpc.org/tpc_documents_current_versions/current_specifications5.asp
cp ~/Downloads/5DAA63D1-0F8F-4FC3-9A66-8F18899EF1B5-TPC-DS-Tool.zip ./files/

docker compose -f docker-compose-tpcds-mariadb.yml up -d --wait

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

#### Copy template files to mariadb dedicated folder
## mkdir -p /kept/mariadb/templates
## cp ../query_templates/* /kept/mariadb/templates/
#### and Adjust it 

#### Generate and split TPC-DS queries
mkdir -p /shared/mariadb/queries/
./dsqgen -OUTPUT_DIR /shared/mariadb/queries \
  -DIRECTORY /kept/mariadb/templates \
  -INPUT /kept/mariadb/templates/templates.lst \
  -VERBOSE Y -QUALIFY Y -DIALECT mariadb 

pushd /shared/mariadb/queries
awk '
  /^-- start/{
    ++part; 
    output_file=sprintf("part-%02d.sql", part);
  }
  {print >> output_file;}
' ./query_0.sql
popd

#### Copy DDL SQLs to shared folder
## mkdir -p /kept/mariadb/ddls/
## cp *.sql /kept/mariadb/ddls/
#### and Adjust it

exit

#--------------------------------------------------------------
### Work in database(MariaDB) container 
docker exec -it mariadb bash

#~~~~~ Adjust the following ddl sqls for correct creatation 
scripts/tpcds-create-ddls.sh

scripts/tpcds-load-data.sh

#~~~~~ Adjust the following query sqls for correct running
scripts/tpcds-run-queries.sh

exit