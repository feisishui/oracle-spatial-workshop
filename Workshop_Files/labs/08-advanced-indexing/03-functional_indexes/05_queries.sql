-- Get all cities in Colorado
select c.city, c.state_abrv
from   us_cities_xy c, us_states s
where  sdo_inside (get_point(c.longitude, c.latitude), s.geom) = 'TRUE'
and    s.state = 'Colorado';

-- Get all cities less than 200 km from Boston
select c1.city, c1.state_abrv
from   us_cities_xy c1, us_cities_xy c2
where  sdo_within_distance (
         get_point(c1.longitude, c1.latitude),
         get_point(c2.longitude, c2.latitude),
         'distance=200 unit=km') = 'TRUE'
and    c2.city = 'Boston';

-- Get all cities less than 200 km from Boston
-- ordered by distance
select c1.city, c1.state_abrv,
       sdo_geom.sdo_distance (
         get_point(c1.longitude, c1.latitude),
         get_point(c2.longitude, c2.latitude),
         0.5,
         'unit=km'
       ) distance
from   us_cities_xy c1, us_cities_xy c2
where  sdo_within_distance (
         get_point(c1.longitude, c1.latitude),
         get_point(c2.longitude, c2.latitude),
         'distance=200 unit=km') = 'TRUE'
and    c2.city = 'Boston'
order  by distance;
