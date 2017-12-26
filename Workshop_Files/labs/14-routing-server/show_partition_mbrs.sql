create table partition_mbr as
select partition_id, sdo_aggr_mbr(geometry) geometry
from node
group by partition_id;

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'PARTITION_MBR',
  'GEOMETRY',
  sdo_dim_array (
    sdo_dim_element ('Longitude', -180, 180, 0.5),
    sdo_dim_element ('Latitude', -90, 90, 0.5)
  ),
  8307
);
commit;

create index partition_mbr_sx on partition_mbr (geometry) indextype is mdsys.spatial_index;


