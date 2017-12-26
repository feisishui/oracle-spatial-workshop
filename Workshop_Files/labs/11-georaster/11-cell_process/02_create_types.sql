CREATE OR REPLACE TYPE location_score AS OBJECT (
  id        NUMBER,
  score_1   NUMBER,
  score_2   NUMBER,
  score_3   NUMBER
);
/
show errors

CREATE OR REPLACE TYPE location_score_table AS TABLE OF location_score;
/
show errors