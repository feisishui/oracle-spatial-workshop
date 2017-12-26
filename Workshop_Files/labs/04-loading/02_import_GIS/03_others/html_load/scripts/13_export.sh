#!/bin/bash
expdp system/oracle directory=DATA_PUMP_WORK_DIR dumpfile=itm.dmp logfile=itm.log "tables=(scott.bassinitm,scott.regionitm)" version=11.2
