select p.condition, i.interstate,
       sum (
         sdo_geom.sdo_length (
           sdo_lrs.clip_geom_segment (
             i.geom,
             p.from_measure,
             p.to_measure),
           0.05)
       ) len
from   us_interstates_lrs i,
       us_road_conditions p
where  i.interstate = p.interstate
group by p.condition, i.interstate
order by p.condition, i.interstate;

