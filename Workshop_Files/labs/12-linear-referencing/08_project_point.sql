-- Project point (-104.60663, 37.3906514) on I25
select sdo_lrs.project_pt (
         geom,
         sdo_geometry (
           2001, 8307,
           sdo_point_type (-104.60663, 37.3906514, null),
           null, null
         )
       )
from   us_interstates_lrs
where  interstate = 'I25';

-- Get measure and offset of point (-104.60663, 37.3906514) on I25
-- Positive offset means the left side
-- Negative offset meand the right side
-- Sides are based on the orientation of the geometry (first point to last point)
select sdo_lrs.find_measure (
         geom,
         sdo_geometry (
           2001, 8307,
           sdo_point_type (-104.606633449958, 37.390651395137, null),
           null, null
         )
       ) accident_measure,
       sdo_lrs.find_offset (
         geom,
         sdo_geometry (
           2001, 8307,
           sdo_point_type (-104.606633449958, 37.390651395137, null),
           null, null
         )
       ) accident_offset
from   us_interstates_lrs
where  interstate = 'I25';
