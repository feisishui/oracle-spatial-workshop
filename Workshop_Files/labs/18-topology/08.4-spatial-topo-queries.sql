-- --------------------------------------------------------------------------
-- 8.4) Perform spatial queries using topology windows
-- --------------------------------------------------------------------------
select county, c.state_abrv
  from us_counties c, us_states_topo s
 where s.state = 'Colorado'
   and sdo_filter (c.geom, s.feature.get_geometry()) = 'TRUE';

select county, c.state_abrv
  from us_counties c, us_states_topo s
 where s.state = 'Colorado'
   and sdo_anyinteract (c.geom, s.feature.get_geometry()) = 'TRUE';

select county, c.state_abrv
  from us_counties c, us_states_topo s
 where s.state = 'Colorado'
   and sdo_inside (c.geom, s.feature.get_geometry()) = 'TRUE';

select county, c.state_abrv
  from us_counties c, us_states_topo s
 where s.state = 'Colorado'
   and sdo_coveredby (c.geom, s.feature.get_geometry()) = 'TRUE';

select county, c.state_abrv
  from us_counties c, us_states_topo s
 where s.state = 'Colorado'
   and sdo_touch (c.geom, s.feature.get_geometry()) = 'TRUE';
