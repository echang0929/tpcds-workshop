#==============================================================
## Prepare for Oracle 19c image 
git clone git@github.com:oracle/docker-images.git

pushd docker-images/OracleDatabase/SingleInstance/dockerfiles/

#~~~~~ Linux ARM64 Support: https://www.oracle.com/database/technologies/oracle19c-linux-arm64-downloads.html
cp ~/Downloads/LINUX.ARM64_1919000_db_home.zip 19.3.0/
./buildContainerImage.sh -v 19.3.0 -e
docker buildx prune -a

popd 

#==============================================================
## Start TPC-DS working
cd docker-compose
mkdir files shared 
#~~~~~ Download TPC-DS package: https://www.tpc.org/tpc_documents_current_versions/current_specifications5.asp
cp ~/Downloads/5DAA63D1-0F8F-4FC3-9A66-8F18899EF1B5-TPC-DS-Tool.zip ./files/

docker compose -f docker-compose-tpcds.yml up -d --wait

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

#### Copy template files to oracle dedicated folder
## mkdir -p /kept/oracle/templates
## cp ../query_templates/* /kept/oracle/templates/
#### and Adjust it 

#### Generate and split TPC-DS queries
mkdir -p /shared/oracle/queries/
./dsqgen -OUTPUT_DIR /shared/oracle/queries -DIRECTORY /kept/oracle/templates -INPUT /kept/oracle/templates/templates.lst -VERBOSE Y -QUALIFY Y -DIALECT oracle 

pushd /shared/oracle/queries
awk '
  /^-- start/{
    ++part; 
    output_file=sprintf("part-%02d.sql", part);
  }
  {print >> output_file;}
' ./query_0.sql
popd

#### Copy DDL SQLs to shared folder
## mkdir -p /kept/oracle/ddls/
## cp *.sql /kept/oracle/ddls/
#### and Adjust it

exit

#--------------------------------------------------------------
### Work in database(Oracle) container 
docker exec -it dbz_oracle19 bash

sqlplus sys/oraclepw as sysdba @/home/oracle/scripts/init-demo.sql

#~~~~~ Adjust the following ddl sqls for correct creatation 
scripts/tpcds-create-ddls.sh

scripts/tpcds-load-data.sh

#~~~~~ Adjust the following query sqls for correct running
scripts/tpcds-run-queries.sh

exit 
