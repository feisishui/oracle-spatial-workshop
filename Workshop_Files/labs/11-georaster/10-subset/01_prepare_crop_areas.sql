drop table crop_areas purge;

-- Create a new table to receive the crop areas
create table crop_areas (
  id number primary key,
  name varchar2(12),
  area sdo_geometry
);

-- Populate the crop areas with a selection of block groups in San Francisco 
insert into crop_areas (id, name, area)
select rownum, tractce||'-'||blkgrpce, geom
from us_blockgroups
where statefp || countyfp in (
  select fipsstco 
  from us_counties 
  where state_abrv = 'CA'
  and county = 'San Francisco'
)
and tractce||blkgrpce in ('0128001','0135001','0111002');
commit;

delete from user_sdo_geom_metadata where table_name = 'CROP_AREAS';

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'CROP_AREAS',
  'AREA',
  sdo_dim_array (
    sdo_dim_element ('Long',-180,180,0.05),
    sdo_dim_element ('Lat',-90,90,0.05)
  ),
  4326
);
commit;

drop index crop_areas_sx;
create index crop_areas_sx on crop_areas(area) indextype is mdsys.spatial_index;
