-- Create table US_INTERSTATES_LRS containing
-- the sections of interstates in Colorado.

-- create the table
drop table us_interstates_lrs;

create table us_interstates_lrs (
  id            number,
  interstate    varchar2(35) primary key,
  geom          sdo_geometry
);

-- Clip interstates at the Colorado border,
-- and insert the clipped geometries into US_INTERSTATES_LRS table.
insert into us_interstates_lrs
  select i.id,
         i.interstate,
         sdo_geom.sdo_intersection(i.geom, s.geom, 0.5) geom
  from   us_states s,
         us_interstates i
  where  s.state_abrv = 'CO'
  and    sdo_anyinteract (i.geom, s.geom) = 'TRUE';

-- insert spatial metadata
delete from user_sdo_geom_metadata
where table_name = 'US_INTERSTATES_LRS' and column_name = 'GEOM';
insert into user_sdo_geom_metadata values (
  'US_INTERSTATES_LRS',
  'GEOM',
  sdo_dim_array (
    sdo_dim_element ('long', -180, 180, 0.5),
    sdo_dim_element ('lat', -90, 90, 0.5)),
  8307);
commit;
