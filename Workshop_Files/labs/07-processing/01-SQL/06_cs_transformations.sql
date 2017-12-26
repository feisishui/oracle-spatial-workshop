--
with gps_locations as (
  select sdo_geometry(2001, 8307, sdo_point_type(-116.2261, 43.606651, null), null, null) position
  from dual
)
select sdo_geom.sdo_distance (
          sdo_cs.transform(g.position, p.geom.sdo_srid), p.geom, 0.05)
from   us_parks_p p,
       gps_locations g
where  p.name = 'Yellowstone NP';
--
select sdo_geom.sdo_distance (
          sdo_cs.transform(
            sdo_geometry(2001, 8307,
              sdo_point_type(-116.2261, 43.606651, null),
              null, null),
            p.geom.sdo_srid),
          p.geom, 0.05)
from   us_parks_p p
where  name = 'Yellowstone NP';
--
select sdo_geom.sdo_distance (
          sdo_geometry(2001, 8307,
            sdo_point_type(-116.2261, 43.606651, null),
            null, null),
          sdo_cs.transform(geom, 8307),
          0.05)
from   us_parks_p
where  name = 'Yellowstone NP';
