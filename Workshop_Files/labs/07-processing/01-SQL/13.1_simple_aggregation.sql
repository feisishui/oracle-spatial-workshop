create table aggregate_tests (test_id number, geom sdo_geometry);

-- Simple aggregation
-- Elapsed: 00:26:57.21 - with VPA:00:00:03.39
INSERT INTO aggregate_tests
SELECT 1.1, sdo_aggr_union(sdoaggrtype(geom,0.5))
FROM us_counties;

-- Simple aggregation with spatial ordering
-- Elapsed:
INSERT INTO aggregate_tests
SELECT 1.2, sdo_aggr_union(sdoaggrtype(geom,0.5))
FROM us_counties
ORDER BY sdo_geom.sdo_min_mbr_ordinate (geom, 1), sdo_geom.sdo_min_mbr_ordinate (geom, 2);
