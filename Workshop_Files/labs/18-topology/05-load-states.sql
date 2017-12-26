-- --------------------------------------------------------------------------
-- 5) Load features US_STATES
-- --------------------------------------------------------------------------

--
-- Insert the hierarchical feature that groups all of the
-- counties in each state, adding the appropriate information
-- into the FEATURE SDO_TOPO_GEOMETRY column
--

insert into us_states_topo (id, state, state_abrv, feature)
  select id, state, state_abrv,
         sdo_topo_map.create_feature (
           'US_LAND_USE',
           'US_STATES_TOPO',
            'FEATURE',
            'STATE_ABRV = ''' || state_abrv ||''''
         )
  from us_states
  where state_abrv in ('CA','UT','NV','CO','NM','AZ');
commit;
