-- Counties on a long river
select c.id, c.county, c.state_abrv
from us_rivers r, us_counties c
where r.name = 'Missouri'
and sdo_within_distance (c.geom, r.geom, 'distance=1 unit=km') = 'TRUE';

select c.id, c.county, c.state_abrv
from us_rivers r, us_counties c
where r.name = 'Missouri'
and sdo_anyinteract (c.geom, r.geom) = 'TRUE';

-- Counties on a short river
select c.id, c.county, c.state_abrv
from us_rivers r, us_counties c
where r.name = 'Richelieu'
and sdo_within_distance (c.geom, r.geom, 'distance=1 unit=km') = 'TRUE';

select c.id, c.county, c.state_abrv
from us_rivers r, us_counties c
where r.name = 'Richelieu'
and sdo_anyinteract (c.geom, r.geom) = 'TRUE';

-- MBR size for long river
select sdo_geom.sdo_area(sdo_geom.sdo_mbr(geom),0.05,'unit=sq_km') km2 
from us_rivers where name = 'Missouri';

-- MBR size for short river
select sdo_geom.sdo_area(sdo_geom.sdo_mbr(geom),0.05,'unit=sq_km') km2 
from us_rivers where name = 'Richelieu';

