-- --------------------------------------------------------------------------
-- 8.1) Perform topology-based queries
-- --------------------------------------------------------------------------

select county, c.state_abrv
  from us_counties_topo c
 where sdo_filter (
         c.feature,
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
  from us_counties_topo c, us_states_topo s
 where s.state = 'Colorado'
   and sdo_filter (c.feature, s.feature) = 'TRUE';

select county, c.state_abrv
  from us_counties_topo c, us_states_topo s
 where s.state = 'Colorado'
   and sdo_anyinteract (c.feature, s.feature) = 'TRUE';

select county, c.state_abrv
  from us_counties_topo c, us_states_topo s
 where s.state = 'Colorado'
   and sdo_inside (c.feature, s.feature) = 'TRUE';

select county, c.state_abrv
  from us_counties_topo c, us_states_topo s
 where s.state = 'Colorado'
   and sdo_coveredby (c.feature, s.feature) = 'TRUE';

select county, c.state_abrv
  from us_counties_topo c, us_states_topo s
 where s.state = 'Colorado'
   and sdo_touch (c.feature, s.feature) = 'TRUE';

select county, c.state_abrv
  from us_counties_topo c, us_states_topo s
 where s.state = 'New York'
   and sdo_touch (c.feature, s.feature) = 'TRUE';
