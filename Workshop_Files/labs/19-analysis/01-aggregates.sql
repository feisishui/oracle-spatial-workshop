select sdo_sam.aggregates_for_layer(
          'US_COUNTIES', 'GEOM',
          'sum', 'totpop',
          'US_CITIES', 'LOCATION',
          'distance=3 unit=mile') from dual;

select *
from
 table (
   sdo_sam.aggregates_for_layer(
          'US_COUNTIES', 'GEOM',
          'sum', 'totpop',
          'US_CITIES', 'LOCATION',
          'distance=3 unit=mile')
 );



SELECT region_id, aggregate_value
from
 table (
   sdo_sam.aggregates_for_layer(
          'US_COUNTIES', 'GEOM',
          'sum', 'totpop',
          'US_CITIES', 'LOCATION',
          'distance=3 unit=mile')
 );


SELECT city, state_abrv, aggregate_value
FROM (
       table (
         sdo_sam.aggregates_for_layer(
                'US_COUNTIES', 'GEOM',
                'sum', 'totpop',
                'US_CITIES', 'LOCATION',
                'distance=3 unit=mile')
       )
      ) a,
      us_cities b
WHERE region_id=b.rowid
ORDER BY aggregate_value;

SELECT c.city, c.state_abrv, a.aggregate_value totpop, b.aggregate_value poppsqmi
FROM  (
       table (
         sdo_sam.aggregates_for_layer(
                'US_COUNTIES', 'GEOM',
                'sum', 'totpop',
                'US_CITIES', 'LOCATION',
                'distance=3 unit=mile')
       )
      ) a,
      (
       table (
         sdo_sam.aggregates_for_layer(
                'US_COUNTIES', 'GEOM',
                'avg', 'poppsqmi',
                'US_CITIES', 'LOCATION',
                'distance=3 unit=mile')
       )
      ) b,
      us_cities c
WHERE a.region_id = c.rowid
AND   b.region_id = c.rowid;


select geometry, aggregate_value, region_id
from table(
     sdo_sam.tiled_aggregates(
      'US_COUNTIES','GEOM','SUM', 'TOTPOP', 5));


---

CREATE TABLE BIN_TILES AS
  SELECT ID, GEOMETRY
  FROM TABLE(SDO_SAM.TILED_BINS(-180,180,-90,90,5,8307));

ALTER TABLE us_cities ADD (bin_id number);

exec SDO_SAM.BIN_LAYER('US_CITIES','LOCATION','BIN_TILES','GEOMETRY','BIN_ID');

create table city_clusters as
SELECT id, geometry
FROM TABLE
  (sdo_sam.spatial_clusters(
     'US_CITIES','LOCATION', 4, 'TRUE'));


insert into user_sdo_geom_metadata select 'CITY_CLUSTERS', 'GEOMETRY', diminfo, srid from user_sdo_geom_metadata where table_name = 'US_CITIES';
commit;
create index city_clusters_sx on city_clusters (geometry) indextype is mdsys.spatial_index;

truncate table city_clusters;
insert into city_clusters
SELECT id, geometry
FROM TABLE
  (sdo_sam.spatial_clusters(
     'US_CITIES','LOCATION', 25, 'TRUE'));
commit;

truncate table city_clusters;
insert into city_clusters
SELECT id, geometry
FROM TABLE
  (sdo_sam.spatial_clusters(
     'US_CITIES','LOCATION', 25, 'FALSE'));
commit;

select id, sdo_geom.sdo_area(geometry, 0.005) area from city_clusters;


--

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
ALTER TABLE us_counties
  ADD smpl_geom sdo_geometry;
begin
  SDO_SAM.SIMPLIFY_LAYER(
    theme_tablename       => 'US_COUNTIES',
    theme_colname         => 'GEOM',
    smpl_geom_colname     => 'SMPL_GEOM',
    commit_interval       => 100,
    pct_area_change_limit => 15
  );
end;

