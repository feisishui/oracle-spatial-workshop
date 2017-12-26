-- Create cities table with X and Y columns for spatial coordinates
drop table us_cities_xy;
create table us_cities_xy as
  select id, city, state_abrv, pop90, rank90,
         c.location.sdo_point.x longitude,
         c.location.sdo_point.y latitude
  from   us_cities c;
