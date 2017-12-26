-- --------------------------------------------------------------------------
-- 7.3) Perform topology queries using spatial windows
-- --------------------------------------------------------------------------
select county, c.state_abrv
  from us_counties_topo c, us_states s
 where s.state = 'Colorado'
   and sdo_filter (c.feature, s.geom) = 'TRUE';

select county, c.state_abrv
  from us_counties_topo c, us_states s
 where s.state = 'Colorado'
   and sdo_anyinteract (c.feature, s.geom) = 'TRUE';

select county, c.state_abrv
  from us_counties_topo c, us_states s
 where s.state = 'Colorado'
   and sdo_inside (c.feature, s.geom) = 'TRUE';

select county, c.state_abrv
  from us_counties_topo c, us_states s
 where s.state = 'Colorado'
   and sdo_coveredby (c.feature, s.geom) = 'TRUE';

select county, c.state_abrv
  from us_counties_topo c, us_states s
 where s.state = 'Colorado'
   and sdo_touch (c.feature, s.geom) = 'TRUE';
