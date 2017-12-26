------------------------------------------------------------
-- Extracting, adding and removing points 
------------------------------------------------------------

select geom from us_interstates where interstate = 'I29B';

-- Extract the second point from interstate I29B;
select get_point (geom, 2)
from us_interstates
where interstate = 'I29B';

-- Extend interstate I29B: add one more point
update us_interstates
set geom = append_point (
  geom,
  sdo_geometry(
    2001, 8307,
    sdo_point_type(-94.850621, 39.77548, null),
    null,null
  )
)
where interstate = 'I29B';

select geom from us_interstates where interstate = 'I29B';

-- Remove the point just added
update us_interstates
set geom = remove_point (geom, 5)
where interstate = 'I29B';

select geom from us_interstates where interstate = 'I29B';

------------------------------------------------------------
-- Constructing a line from a set of points
------------------------------------------------------------
drop table points purge;
create table points as
select i.id oid, p.id pid, p.x, p.y
from us_interstates i,
	   table(sdo_util.getvertices (geom)) p
where interstate like '%91%';

drop table lines purge;
create table lines as
select oid, make_line (
  cursor (
    select x, y
    from   points
    where  oid = p.oid
    ORDER BY pid
  ),
  4326
) geom
from (
  select distinct oid 
  from points
) p;

------------------------------------------------------------
-- Constructing a polygon from a set of points
------------------------------------------------------------

drop table points purge;
create table points as
select c.id oid, p.id pid, p.x, p.y
from   us_counties c,
	   table(sdo_util.getvertices (geom)) p
where  state_abrv = 'NH';

drop table polygons purge;
create table polygons as
select oid, make_polygon (
  cursor (
    select x, y
    from   points
    where  oid = p.oid
    ORDER BY pid
  ),
  4326,
  'false'
) geom
from (
  select distinct oid 
  from points
) p;

------------------------------------------------------------
-- Splitting a multi-geometry into its elements
------------------------------------------------------------
select * from table(get_elements((select geom from us_states where state_abrv='CA')));

select id, state_abrv, element_id, element_geom
from   us_states, table(get_elements(geom))
order by id, element_id;

select element_id, element_geom
from us_states, table(get_elements(geom))
where state_abrv = 'CA'
order by element_id;

select id, county, state_abrv, element_id, element_geom
from   us_counties, table(get_elements(geom))
where state_abrv = 'CO'
and county in ('Denver', 'Arapahoe')
order by id, element_id;

select s.state_abrv, s.state, e.element_id, e.element_geom
from us_states s, table(get_elements(geom)) e
where s.state_abrv = 'CA'
order by e.element_id;

create table us_states_elements as
select id, state_abrv, element_id, element_geom
from   us_states, table(get_elements(geom));

