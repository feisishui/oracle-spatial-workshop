-- Create view to hide the function call
create or replace view us_cities_xy_v as
select id, city, state_abrv, pop90, rank90, get_point(longitude,latitude) as location
from us_cities_xy;
