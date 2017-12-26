-- Create the function that constructs a point geometry from a geocoding result
create or replace function gc_point (
  gc_result sdo_geo_addr
)
return sdo_geometry
deterministic
as
begin
  if gc_result is not null then
    return sdo_geometry (2001, gc_result.srid,
      sdo_point_type (
        gc_result.longitude, gc_result.latitude, null),
      null, null
    );
  else
    return null;
  end if;
end;
/

-- Setup spatial metadata for the function-based index
delete from user_sdo_geom_metadata
where table_name = 'GC_RESULTS';

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'GC_RESULTS', 
  'SCOTT.GC_POINT(GC_RESULT)',
  sdo_dim_array (
    sdo_dim_element('Longitude', -180.0, 180.0, 0.05),
    sdo_dim_element('Latitude', -90.0, 90.0, 0.05)
  ),
  8307
);
commit;

-- create the function-based spatial index
drop index gc_results_sx;
create index gc_results_sx
  on gc_results (gc_point(gc_result))
  indextype is mdsys.spatial_index;

-- Search for addresses within distance from a point
select id, gc_point(gc_result)
from gc_results g
where sdo_within_distance (
  gc_point(gc_result),
  SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE(-122.49586, 37.77904, NULL), NULL, NULL),
  'DISTANCE=2 UNIT=KM'
) = 'TRUE';
  
-- Create the view
create or replace view gc_results_geom as
select id, gc_point(gc_result) as gc_geom
from gc_results;

-- Search for addresses within distance from a point
select id, gc_geom
from gc_results_geom g
where  sdo_within_distance (
  gc_geom,
  SDO_GEOMETRY(2001, 8307, SDO_POINT_TYPE(-122.49586, 37.77904, NULL), NULL, NULL),
  'DISTANCE=2 UNIT=KM'
) = 'TRUE';

