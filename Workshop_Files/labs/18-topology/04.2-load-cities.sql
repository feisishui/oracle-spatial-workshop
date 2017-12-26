-- --------------------------------------------------------------------------
-- 4.2) Load features US_CITIES
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
    FROM US_CITIES
    WHERE STATE_ABRV in ('CA','UT','NV','CO','NM','AZ')
    ORDER BY ID
  )
  LOOP
    topo_geom := SDO_TOPO_MAP.CREATE_FEATURE (
      'US_LAND_USE',
      'US_CITIES_TOPO',
      'FEATURE',
      r.location);

    -- Associate topological primitives with features
    INSERT INTO US_CITIES_TOPO (
      ID,
      CITY,
      STATE_ABRV,
      POP90,
      RANK90,
      FEATURE
    )
    VALUES (
      r.ID,
      r.CITY,
      r.STATE_ABRV,
      r.POP90,
      r.RANK90,
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
