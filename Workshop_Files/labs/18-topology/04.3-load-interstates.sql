-- --------------------------------------------------------------------------
-- 4.3) Load features US_INTERSTATES
-- --------------------------------------------------------------------------

--
-- Create updatable TopoMap object
--

EXECUTE sdo_topo_map.create_topo_map('US_LAND_USE', 'my_topo_map_cache');

--
-- Load the whole topology in cache. Since the topology was
-- just created, the cache will be empty.  If this was not an initial
-- bulk load, use SDO_TOPO_MAP.LOAD_TOPO_MAP specifying the
-- coordinates of the window to load
--

EXECUTE sdo_topo_map.load_topo_map('my_topo_map_cache', 'true');


DECLARE
  topo_geom  SDO_TOPO_GEOMETRY;
BEGIN

  FOR r IN (
    SELECT *
    FROM US_INTERSTATES
    WHERE INTERSTATE IN ('I70','I76','I225')
    ORDER BY ID
  )
  LOOP
    topo_geom := SDO_TOPO_MAP.CREATE_FEATURE (
      'US_LAND_USE',
      'US_INTERSTATES_TOPO',
      'FEATURE',
      r.geom);

    -- Associate topological primitives with features
    INSERT INTO US_INTERSTATES_TOPO (
      ID,
      INTERSTATE,
      FEATURE
    )
    VALUES (
      r.ID,
      r.INTERSTATE,
      topo_geom
    );
    COMMIT;
  END LOOP;
END;
/

--
-- Commit all changes.  Since create feature was used, the
-- changes include topological primitive changes and the feature
-- table inserts
--

EXECUTE sdo_topo_map.commit_topo_map;

--
-- Drop the TOPO_MAP cache
--

EXECUTE sdo_topo_map.drop_topo_map('my_topo_map_cache');
