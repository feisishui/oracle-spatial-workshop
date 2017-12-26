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
     'US_CITIES','LOCATION', 4, 'TRUE'));
commit;

truncate table city_clusters;
insert into city_clusters
SELECT id, geometry
FROM TABLE
  (sdo_sam.spatial_clusters(
     'US_CITIES','LOCATION', 25, 'FALSE'));
commit;

select id, sdo_geom.sdo_area(geometry, 0.005) area from city_clusters;

