-- --------------------------------------------------------------------------
-- 4.1) Load features US_COUNTIES
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

--
-- The COUNTIES table contains an SDO_GEOMETRY column.
-- Decompose the counties into their topological primitives,
-- and store them as topology features.
--

DECLARE
  topo_geom  SDO_TOPO_GEOMETRY;
BEGIN

  -- Counties table contains an SDO_GEOMETRY column.  Decompose the counties
  -- into topological primitives

  FOR r IN (
    SELECT *
    FROM US_COUNTIES
    WHERE STATE_ABRV in ('CA','UT','NV','CO','NM','AZ')
    ORDER BY ID
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
      r.ID,
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
