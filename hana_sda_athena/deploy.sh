# !/bin/bash
# PARAM1: s3 Bucketname e.g. s3://aws-athena-hana-int/logs/
# PARAM2: AWS Region e.g. eu-central-1
# Defaults <sid> = HDB, <sid>adm = hdbadm
# Athena ODBC Driver version 1.0.5

zypper install -y unixODBC

mkdir AthenaODBC

cd AthenaODBC

wget https://s3.amazonaws.com/athena-downloads/drivers/ODBC/SimbaAthenaODBC_1.0.5/Linux/simbaathena-1.0.5.1006-1.x86_64.rpm

zypper --no-gpg-checks install -y simbaathena-1.0.5.1006-1.x86_64.rpm


su hdbadm

cd /usr/sap/HDB/home

cat > .odbc.ini <<EOF
[Data Sources]
MyDSN=Simba Athena ODBC Driver 64-bit
[MyDSN]
Driver=/opt/simba/athenaodbc/lib/64/libathenaodbc_sb64.so
AuthenticationType=Instance Profile
AwsRegion=eu-central-1
S3OutputLocation=s3://aws-athena-hana-int/logs/
EOF

cat > .customer.sh <<EOF
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/simba/athenaodbc/lib/64/
export ODBCINI=$HOME/.odbc.ini
EOF

chmod 700 .customer.sh

# Test
isql MyDSN -c -d

sudo -i

cd /usr/sap/HDB/SYS/exe/hdb/config

cat > Property_Athena.ini <<EOF
CAP_SUBQUERY : true
CAP_ORDERBY : true
CAP_JOINS : true
CAP_GROUPBY : true
CAP_AND : true
CAP_OR : true
CAP_TOP : false
CAP_LIMIT : true
CAP_SUBQUERY :  true
CAP_SUBQUERY_GROUPBY : true

FUNC_ABS : true
FUNC_ADD : true
FUNC_ADD_DAYS : DATE_ADD(DAY,$2,$1)
FUNC_ADD_MONTHS : DATE_ADD(MONTH,$2,$1)
FUNC_ADD_SECONDS : DATE_ADD(SECOND,$2,$1)
FUNC_ADD_YEARS : DATE_ADD(YEAR,$2,$1)
FUNC_ASCII : true
FUNC_ACOS : true
FUNC_ASIN : true
FUNC_ATAN : true
FUNC_TO_VARBINARY : false
FUNC_TO_VARCHAR : false
FUNC_TO_NVARCHAR : CAST($1 AS varchar)
FUNC_TO_INT : CAST($1 AS integer)
FUNC_TO_DECIMAL : CAST ($1 AS double) 
FUNC_TRIM_BOTH : TRIM($1)         
FUNC_TRIM_LEADING : LTRIM($1)
FUNC_TRIM_TRAILING : RTRIM($1)
FUNC_UMINUS : false
FUNC_UPPER : true  
FUNC_WEEKDAY : false

TYPE_TINYINT : TINYINT
TYPE_LONGBINARY : VARBINARY
TYPE_LONGCHAR : VARBINARY
TYPE_DATE : DATE
TYPE_TIME : TIME
TYPE_DATETIME : TIMESTAMP
TYPE_REAL : REAL
TYPE_SMALLINT : SMALLINT
TYPE_INT : INTEGER
TYPE_INTEGER : INTEGER
TYPE_FLOAT : DOUBLE
TYPE_CHAR : CHAR($PRECISION)
TYPE_BIGINT : DECIMAL(19,0)
TYPE_DECIMAL : DECIMAL($PRECISION,$SCALE)
TYPE_VARCHAR : VARCHAR($PRECISION)
TYPE_BINARY : VARBINARY
TYPE_VARBINARY : VARBINARY
TYPE_NVARCHAR : STRING

PROP_USE_UNIX_DRIVER_MANAGER : true
EOF

chmod 444 Property_Athena.ini

chown hdbadm:sapsys Property_Athena.ini