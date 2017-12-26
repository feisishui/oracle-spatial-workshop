CREATE TABLE colocation_table(
    colocation_id number,
    layer_rowid varchar2(24),
    theme_rowid varchar2(24));

DROP TABLE colocation_table;
CREATE TABLE colocation_table(
    colocation_id number,
    layer_rowid rowid,
    theme_rowid rowid
);

begin
  SDO_SAM.COLOCATED_REFERENCE_FEATURES(
    'US_CITIES','LOCATION','pop90 > 120000',
    'US_INTERSTATES','GEOM', NULL,
    'distance=20 unit=km','COLOCATION_TABLE',30);
end;
/
