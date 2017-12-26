-- Run the query on 2D data
select county, c.state_abrv
 from us_states_p s,
      us_counties_p c
 where s.state = 'New York'
   and sdo_anyinteract (c.geom, s.geom) = 'TRUE';

-- 85 rows selected.
-- Elapsed: 00:00:00.23


-- Convert counties to 3D
create table us_counties_p_3D as
select * from us_counties_p;

update us_counties_p_3d set geom = sdo_cs.make_3d(geom);

delete from user_sdo_geom_metadata
  where table_name = 'US_COUNTIES_P_3D' and column_name = 'GEOM' ;

insert into user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
values (
  'US_COUNTIES_P_3D',
  'GEOM',
  sdo_dim_array (
    sdo_dim_element('x', -11000000, 4000000, 0.5),
    sdo_dim_element('y', -80000, 7000000, 0.5),
    sdo_dim_element('Z', -1000, 1000, 0.5)
  ),
  32775
);

-- Create a 3D index
drop index us_counties_p_3d_sx;
create index us_counties_p_3d_sx on us_counties_p_3d (geom)
  indextype is mdsys.spatial_index
  parameters ('sdo_indx_dims=3');

-- Run the query on the 3D table, using the 3D index
select county, c.state_abrv
 from us_states_p s,
      us_counties_p_3d c
 where s.state = 'New York'
   and sdo_anyinteract (c.geom, s.geom) = 'TRUE';

-- 85 rows selected.
-- Elapsed: 00:01:10.76

-- Create a 2D index
drop index us_counties_p_3d_sx;
create index us_counties_p_3d_sx on us_counties_p_3d (geom)
  indextype is mdsys.spatial_index;

-- Run the query on the 3D table, using the 2D index
select county, c.state_abrv
 from us_states_p s,
      us_counties_p_3d c
 where s.state = 'New York'
   and sdo_anyinteract (c.geom, s.geom) = 'TRUE';

-- 85 rows selected.
-- Elapsed: 00:00:00.25