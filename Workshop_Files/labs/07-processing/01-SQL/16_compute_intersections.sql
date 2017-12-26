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

select n_matches, count(*)
from (
  select rowid1, ceil(count(*)/10)*10 n_matches
  from park_matches_filter
  group by rowid1
)
group by n_matches
order by n_matches;


-- Step 2: compare geometries and compute intersections
-- Without VPA: Elapsed: 
-- With VPA: Elapsed: 00:13:30.35
DROP TABLE park_matches PURGE;
CREATE TABLE park_matches NOLOGGING NOPARALLEL AS
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
FROM   (
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
  AND    m.rowid2 = p.rowid
)
WHERE relation not in ('TOUCH', 'DISJOINT');
-- Check counts
col relation for a20
SELECT relation, count(*) cases
FROM   park_matches
GROUP BY relation
ORDER BY relation;


