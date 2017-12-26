-- Extract the scores
CREATE TABLE us_pois_scores NOLOGGING AS
SELECT /*+ parallel(2) */ * 
FROM TABLE (
  score_pipelined (CURSOR (SELECT id, geometry FROM us_pois))
);

-- Update the base table with the scores
UPDATE /*+ parallel(2) */ us_pois p
  SET (score_1, score_2, score_3) = (
    SELECT score_1, score_2, score_3
    FROM us_pois_scores s
    WHERE s.id = p.id
);
commit;
