-- --------------------------------------------------------------------------
-- 9.1) Make changes for testing topology queries
-- --------------------------------------------------------------------------

-- Must remove hierarchical features based on counties in Colorado
-- This is so I can remove one of the underlying features that form Colorado
-- If not:
/*
delete from us_counties_topo where county = 'Denver'
*
ERROR at line 1:
ORA-29876: failed in the execution of the ODCIINDEXDELETE routine
ORA-13199:  Cannot delete a TG object with dependent parent objects
ORA-06512: at "MDSYS.MD", line 1723
ORA-06512: at "MDSYS.MDERR", line 17
ORA-06512: at "MDSYS.SDO_TPIDX", line 614
ORA-06512: at "MDSYS.SDO_INDEX_METHOD_10I", line 795
*/
delete from us_states_topo where state = 'Colorado';

-- Remove one feature (will create an empty spot in our data)
delete from us_counties_topo where county = 'Denver';

-- Duplicate one feature (will create an overlap in our data)
EXECUTE sdo_topo_map.create_topo_map('US_LAND_USE', 'my_topo_map_cache');
EXECUTE sdo_topo_map.load_topo_map('my_topo_map_cache', 'true');

DECLARE
  topo_geom  SDO_TOPO_GEOMETRY;
BEGIN

  FOR r IN (
    SELECT *
    FROM US_COUNTIES
    WHERE STATE_ABRV = 'CO'
    AND COUNTY = 'El Paso'
  )
  LOOP
    topo_geom := SDO_TOPO_MAP.CREATE_FEATURE (
      'US_LAND_USE',
      'US_COUNTIES_TOPO',
      'FEATURE',
      r.geom);

    -- Associate topological primitives with features
    INSERT INTO US_COUNTIES_TOPO (
      ID,
      COUNTY,
      FIPSSTCO,
      STATE,
      STATE_ABRV,
      FIPSST,
      LANDSQMI,
      TOTPOP,
      POPPSQMI,
      FEATURE
    )
    VALUES (
      r.ID+10000,
      r.COUNTY,
      r.FIPSSTCO,
      r.STATE,
      r.STATE_ABRV,
      r.FIPSST,
      r.LANDSQMI,
      r.TOTPOP,
      r.POPPSQMI,
      topo_geom
    );
  END LOOP;
END;
/
EXECUTE sdo_topo_map.commit_topo_map;
EXECUTE sdo_topo_map.drop_topo_map('my_topo_map_cache');

-- Restore Colorado
-- The state now has 63 counties: Denver was removed, but El Paso was added back in as a duplicate.
insert into us_states_topo (id, state, state_abrv, feature)
  select id, state, state_abrv,
         sdo_topo_map.create_feature (
           'US_LAND_USE',
           'US_STATES_TOPO',
            'FEATURE',
            'STATE_ABRV = ''' || state_abrv ||''''
         )
    from us_states
    where state = 'Colorado';
    
commit;
