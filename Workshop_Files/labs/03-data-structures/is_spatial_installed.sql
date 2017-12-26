-- Check the database registry
col comp_id for a7
col comp_name format a25
col version format a25
col status format a15
select comp_id, comp_name, version, status
from dba_registry
where comp_id in ('SDO', 'ORDIM');

-- Check the presence of spatial packages
select case count(*) when 0 then 'FALSE' else 'TRUE' end spatial_installed
from dba_objects
where owner = 'MDSYS'
and object_type = 'PACKAGE'
and object_name in (
  'SDO_GCDR',
  'SDO_GEOR',
  'SDO_NET' ,
  'SDO_TOPO',
  'SDO_SAM',
  'SDO_LRS',
  'SDO_WS_PROCESS',
  'SDO_WFS_PROCESS',
  'SDO_CSW_PROCESS',
  'SDO_OLS',
  'SDO_TIN_PKG',
  'SDO_PC_PKG'
);

