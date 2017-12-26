-- Get all cities in Colorado
select c.city, c.state_abrv
from   us_cities_xy_v c, us_states s
where  sdo_inside (c.location, s.geom) = 'TRUE'
and    s.state = 'Colorado';

-- Get all cities less than 200 km from Boston
select c1.city, c1.state_abrv
from   us_cities_xy_v c1, us_cities_xy_v c2
where  sdo_within_distance (
         c1.location,
         c2.location,
         'distance=200 unit=km') = 'TRUE'
and    c2.city = 'Boston';

-- Get all cities less than 200 km from Boston
-- ordered by distance
select c1.city, c1.state_abrv,
       sdo_geom.sdo_distance (
         c1.location,
         c2.location,
         0.5,
         'unit=km'
       ) distance
from   us_cities_xy_v c1, us_cities_xy_v c2
where  sdo_within_distance (
         c1.location,
         c2.location,
         'distance=200 unit=km') = 'TRUE'
and    c2.city = 'Boston'
order  by distance;
