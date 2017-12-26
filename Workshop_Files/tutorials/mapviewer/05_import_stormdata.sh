#!/bin/bash -x

# This assumes that the input dump file (storm_expdp.dmp) is in the default IMPDP directory
# DATA_PUMP_DIR pointing to $ORACLE_BASE/admin/$ORACLE_SID/dpdump = /home/oracle/app/oracle/admin/orcl121/dpdump

impdp mvdemo/mvdemo \
  remap_schema=disaster:mvdemo \
  remap_tablespace=system:users \
  directory=data_pump_dir \
  dumpfile=storm_expdp.dmp \
  logfile=storm_expdp.log \
  full=yes \
  TABLE_EXISTS_ACTION=APPEND

read -p "Hit return to continue... " X
