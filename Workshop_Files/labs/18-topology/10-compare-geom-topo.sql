col relate for a60
select *
from (
  select g.id, sdo_geom.relate (g.geom, 'determine', t.feature.get_geometry(), 0.05) relate
  from us_counties g, us_counties_topo t
  where g.id = t.id
)
where relate <> 'EQUAL'
order by id;

select *
from (
  select g.id, sdo_geom.relate (g.location, 'determine', t.feature.get_geometry(), 0.05) relate
  from us_cities g, us_cities_topo t
  where g.id = t.id
)
where relate <> 'EQUAL'
order by id;

select *
from (
  select g.id, sdo_geom.relate (g.geom, 'determine', t.feature.get_geometry(), 0.05) relate
  from us_interstates g, us_interstates_topo t
  where g.id = t.id
)
where relate <> 'EQUAL'
order by id;
