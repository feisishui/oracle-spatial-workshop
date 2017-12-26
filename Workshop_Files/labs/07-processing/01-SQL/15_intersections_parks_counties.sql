-- NOTE: disable parallelism since I am running on a single-core VM
alter session force parallel query parallel 1;

-- Step 1: find approximate correlations
-- Elapsed: 00:00:03.20
DROP TABLE park_matches_filter PURGE;
CREATE TABLE park_matches_filter AS
SELECT rowid1, rowid2
FROM   TABLE (
         SDO_JOIN (
           'US_COUNTIES', 'GEOM',   
           'US_PARKS', 'GEOM'
         ) 
       );
-- Check counts
SELECT count(*)
FROM park_matches_filter;

-- Step 2: compare geometries
-- Without VPA: Elapsed: 00:01:28.13
-- With VPA: Elapsed: 00:00:47.82
DROP TABLE park_matches_compare PURGE;
CREATE TABLE park_matches_compare NOLOGGING PARALLEL AS
SELECT /*+ ordered use_nl (m,p) use_nl (m,c) */
       c.id county_id, 
       p.id park_id,
       c.geom county_geom, 
       p.geom park_geom,
       sdo_geom.relate (
         c.geom, 'DETERMINE', p.geom, 0.05
       ) relation
FROM   park_matches_filter m , us_counties c,  us_parks p
WHERE  m.rowid1 = c.rowid
AND    m.rowid2 = p.rowid;
-- Check counts
col relation for a20
SELECT relation, cases, 
       case 
         when relation in ('COVERS', 'CONTAINS', 'COVEREDBY', 'INSIDE', 'EQUAL', 'TOUCH', 'DISJOINT')
           then 'N'
         else
           'Y'    
       end intersection_needed
FROM (
  SELECT relation, count(*) cases
  FROM   park_matches_compare
  GROUP BY relation
)
ORDER BY relation;

-- Step 3: compute intersections
-- Without VPA: Elapsed: 00:04:51.47
-- With VPA: Elapsed: 00:04:57.21
DROP TABLE park_matches PURGE;
CREATE TABLE park_matches NOLOGGING PARALLEL AS
SELECT county_id,
       park_id,
       relation,
       case 
         when relation in ('COVERS', 'CONTAINS', 'EQUAL')
           then county_geom
         when relation in ('COVEREDBY', 'INSIDE')
           then park_geom
         else
           sdo_geom.sdo_intersection (county_geom, park_geom, 0.05)    
       end intersection_geom
FROM   park_matches_compare
WHERE  relation not in ('TOUCH', 'DISJOINT');
-- Check counts
col relation for a20
SELECT relation, count(*) cases
FROM   park_matches
GROUP BY relation
ORDER BY relation;


