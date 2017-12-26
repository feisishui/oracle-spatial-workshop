-- clip and return interstate segments where road condition is "poor"
select i.interstate,
       sdo_lrs.clip_geom_segment (
         i.geom,
         p.from_measure,
         p.to_measure) geom
from   us_interstates_lrs i,
       us_road_conditions p
where  i.interstate = p.interstate
and    p.condition = 'poor';
