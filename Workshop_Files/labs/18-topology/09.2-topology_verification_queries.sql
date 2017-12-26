-- --------------------------------------------------------------------------
-- 9.2) Queries on topology tables
-- --------------------------------------------------------------------------

-- Identify blank areas = faces not used by any area feature
-- This reports multiple faces because the county we removed 
-- is split in pieces by the interstates that cross it
SELECT FACE_ID
FROM   US_LAND_USE_FACE$
WHERE  FACE_ID NOT IN (
  SELECT TOPO_ID 
  FROM US_LAND_USE_RELATION$ 
  WHERE TOPO_TYPE = 3
)
AND    FACE_ID >= 0
ORDER  BY FACE_ID;

-- Identify overlaps = faces used by more than one area feature
-- One face is used by two features
SELECT TOPO_ID FACE_ID, COUNT(*)
FROM   US_LAND_USE_RELATION$
WHERE  TOPO_ID > 1
AND    TOPO_TYPE = 3
GROUP BY TOPO_ID
HAVING COUNT(*) > 1;

-- What are the overlapping features ?
SELECT ID, STATE_ABRV, COUNTY
FROM   US_COUNTIES_TOPO C
WHERE  C.FEATURE.TG_ID IN (
  SELECT TG_ID
  FROM   US_LAND_USE_RELATION$
  WHERE  TOPO_ID IN (
    SELECT TOPO_ID
    FROM   US_LAND_USE_RELATION$
    WHERE  TOPO_ID > 1
    AND    TOPO_TYPE = 3
    GROUP BY TOPO_ID
    HAVING COUNT(*) > 1
  )
);
