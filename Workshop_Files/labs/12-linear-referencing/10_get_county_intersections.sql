-- This clips the section of I25 that traverses county El Paso
select sdo_lrs.lrs_intersection (i.geom, c.geom, 0.5)
from   us_interstates_lrs i, us_counties c
where  i.interstate='I25'
and    c.county = 'El Paso'
and    c.state_abrv = 'CO';

-- Get the measures on I25 as it crosses El Paso county line
select sdo_lrs.geom_segment_length (geom) length,
       sdo_lrs.geom_segment_start_pt (geom) start_pt,
       sdo_lrs.geom_segment_end_pt (geom) end_pt,
       sdo_lrs.geom_segment_start_measure (geom) start_measure,
       sdo_lrs.geom_segment_end_measure (geom) end_measure
from   (
  select sdo_lrs.lrs_intersection (i.geom, c.geom, 0.5) geom
  from   us_interstates_lrs i, us_counties c
  where  i.interstate='I25'
  and    c.county = 'El Paso'
  and    c.state_abrv = 'CO');

-- Find the intersection of I225 with the counties it traverses
-- NOTE: for counties Denver and Arapahoe, the result is a multi-line string
select c.county, sdo_lrs.lrs_intersection (i.geom, c.geom, 0.5)
from   us_interstates_lrs i, us_counties c
where  i.interstate='I225'
and    sdo_anyinteract (c.geom, i.geom) = 'TRUE';

-- Get the measures on I225 as it crosses overlapping counties
select county,
       sdo_lrs.geom_segment_length (geom) length,
       sdo_lrs.geom_segment_start_pt (geom) start_pt,
       sdo_lrs.geom_segment_end_pt (geom) end_pt,
       sdo_lrs.geom_segment_start_measure (geom) start_measure,
       sdo_lrs.geom_segment_end_measure (geom) end_measure
from   (
  select c.county, sdo_lrs.lrs_intersection (i.geom, c.geom, 0.5) geom
  from   us_interstates_lrs i, us_counties c
  where  i.interstate='I225'
  and    sdo_anyinteract (c.geom, i.geom) = 'TRUE');
