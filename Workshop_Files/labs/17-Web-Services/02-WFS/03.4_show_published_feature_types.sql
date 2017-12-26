-- Features published in the database
col owner for a20
col table_name for a30
select featuretypeid,
       substr(dataPointer, 1, instr(dataPointer,'.')-1) owner,
       substr(dataPointer, instr(dataPointer,'.')+1) table_name,
       namespacePrefix || ':' || featureTypeName featureTypeName
from   mdsys.WFS_FeatureType$
order  by owner, table_name;
