-- --------------------------------------------------------------------------
-- 8.2) Perform spatial queries
-- --------------------------------------------------------------------------

select county, c.state_abrv
  from us_counties c
 where sdo_filter (
         c.geom,
         sdo_geometry(
           2003, 8307, null,
           sdo_elem_info_array (1, 1003, 3),
           sdo_ordinate_array(
              -109.0594, 36.992416,
              -102.04113, 41.002956
           )
         )
       ) = 'TRUE';

select county, c.state_abrv
  from us_counties c, us_states s
 where s.state = 'Colorado'
   and sdo_filter (c.geom, s.geom) = 'TRUE';

select county, c.state_abrv
  from us_counties c, us_states s
 where s.state = 'Colorado'
   and sdo_anyinteract (c.geom, s.geom) = 'TRUE';

select county, c.state_abrv
  from us_counties c, us_states s
 where s.state = 'Colorado'
   and sdo_inside (c.geom, s.geom) = 'TRUE';

select county, c.state_abrv
  from us_counties c, us_states s
 where s.state = 'Colorado'
   and sdo_coveredby (c.geom, s.geom) = 'TRUE';

select county, c.state_abrv
  from us_counties c, us_states s
 where s.state = 'Colorado'
   and sdo_touch (c.geom, s.geom) = 'TRUE';

select county, c.state_abrv
  from us_counties c, us_states s
 where s.state = 'New York'
   and sdo_touch (c.geom, s.geom) = 'TRUE';
