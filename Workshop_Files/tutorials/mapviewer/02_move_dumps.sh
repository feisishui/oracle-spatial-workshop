#!/bin/bash -x
cd "$(dirname "$0")"

# Move the dump files to the default IMPDP directory
# i.e. $ORACLE_BASE/admin/$ORACLE_SID/dpdump = /home/oracle/app/oracle/admin/orcl121/dpdump

sudo mv -v dmp/naturalearth/mvdemo_naturalearth.dmp $ORACLE_BASE/admin/$ORACLE_SID/dpdump
sudo mv -v dmp/storm-data/storm_expdp.dmp $ORACLE_BASE/admin/$ORACLE_SID/dpdump

read -p "Hit return to continue... "
