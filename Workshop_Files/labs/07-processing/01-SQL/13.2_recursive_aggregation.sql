-- Recursive aggregation
-- Elapsed: 00:01:18.28
INSERT INTO aggregate_tests
SELECT 2.1, sdo_aggr_union(sdoaggrtype(aggr_geom,0.5)) aggr_geom
FROM (
  SELECT sdo_aggr_union(sdoaggrtype(aggr_geom,0.5)) aggr_geom
  FROM (
    SELECT sdo_aggr_union(sdoaggrtype(aggr_geom,0.5)) aggr_geom
    FROM (
      SELECT sdo_aggr_union(sdoaggrtype(aggr_geom,0.5)) aggr_geom
      FROM (
        SELECT sdo_aggr_union(sdoaggrtype(geom,0.5)) aggr_geom
        FROM us_counties
        GROUP BY mod(rownum, 128)
      )
      GROUP BY mod (rownum, 32)
    )
    GROUP BY mod (rownum, 8)
  )
  GROUP BY mod (rownum, 2)
);

-- Recursive aggregation with spatial ordering
-- Elapsed: Elapsed: 00:01:24.42
INSERT INTO aggregate_tests
  SELECT 2.2, sdo_aggr_union(sdoaggrtype(aggr_geom,0.5)) aggr_geom
  FROM (
    SELECT sdo_aggr_union(sdoaggrtype(aggr_geom,0.5)) aggr_geom
    FROM (
      SELECT sdo_aggr_union(sdoaggrtype(aggr_geom,0.5)) aggr_geom
      FROM (
        SELECT sdo_aggr_union(sdoaggrtype(aggr_geom,0.5)) aggr_geom
        FROM (
          SELECT sdo_aggr_union(sdoaggrtype(geom,0.5)) aggr_geom
          FROM (
            SELECT geom
            FROM us_counties
            ORDER BY sdo_geom.sdo_min_mbr_ordinate (geom, 1), sdo_geom.sdo_min_mbr_ordinate (geom, 2)
          )
          GROUP BY mod(rownum, 128)
        )
        GROUP BY mod (rownum, 32)
      )
      GROUP BY mod (rownum, 8)
    )
    GROUP BY mod (rownum, 2)
  );

