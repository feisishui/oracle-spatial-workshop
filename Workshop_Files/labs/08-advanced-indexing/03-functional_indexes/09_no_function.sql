-- Setup spatial metadata for the function-based index
delete from user_sdo_geom_metadata
  where table_name = 'US_CITIES_XY';

-- IMPORTANT: The column expression must NOT contain any SPACES
-- If not: ORA-13199: wrong column name: ...
insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'US_CITIES_XY', 
  'MDSYS.SDO_GEOMETRY(2001,8307,SDO_POINT_TYPE(LONGITUDE,LATITUDE,NULL),NULL,NULL)',
  sdo_dim_array (
    sdo_dim_element('long', -180.0, 180.0, 0.5),
    sdo_dim_element('lat', -90.0, 90.0, 0.5)
  ),
  8307
);
commit;

-- create the function-based spatial index
drop index us_cities_xy_sx;
create index us_cities_xy_sx
  on us_cities_xy (sdo_geometry(2001, 8307, sdo_point_type(longitude, latitude, null), null, null))
  indextype is mdsys.spatial_index;

-- Perform queries
select c.city, c.state_abrv
from   us_cities_xy c, us_states s
where  sdo_inside (
         sdo_geometry(2001,8307,sdo_point_type(c.longitude,c.latitude,null),null,null), 
         s.geom
       ) = 'TRUE'
and    s.state = 'Colorado';

-- Create view to hide the function call
create or replace view us_cities_xy_v as
select id, city, state_abrv, pop90, rank90, sdo_geometry(2001,8307,sdo_point_type(longitude,latitude,null),null,null) as location
from us_cities_xy;

-- Perform queries on view
select c.city, c.state_abrv
from   us_cities_xy_v c, us_states s
where  sdo_inside (c.location, s.geom) = 'TRUE'
and    s.state = 'Colorado';

