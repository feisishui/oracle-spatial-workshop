#!/bin/bash -x

# This assumes that the input dump file (mvdemo_naturalearth.dmp) is in the default IMPDP directory
# DATA_PUMP_DIR pointing to $ORACLE_BASE/admin/$ORACLE_SID/dpdump = /home/oracle/app/oracle/admin/orcl121/dpdump

impdp mvdemo/mvdemo \
  remap_schema=nedata:mvdemo \
  remap_tablespace=system:users \
  directory=data_pump_dir \
  dumpfile=mvdemo_naturalearth.dmp \
  logfile=mvdemo_naturalearth.log \
  full=yes \
  exclude=grant \
  TABLE_EXISTS_ACTION=APPEND

read -p "Hit return to continue... "
