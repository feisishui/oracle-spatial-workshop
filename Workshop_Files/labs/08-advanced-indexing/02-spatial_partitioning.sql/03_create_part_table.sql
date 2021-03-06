DROP TABLE yellow_pages_part_spatial;

CREATE TABLE yellow_pages_part_spatial
PARTITION BY RANGE (cell_id) (
  PARTITION p01 VALUES LESS THAN (2),
  PARTITION p02 VALUES LESS THAN (3),
  PARTITION p03 VALUES LESS THAN (4),
  PARTITION p04 VALUES LESS THAN (5),
  PARTITION p05 VALUES LESS THAN (6),
  PARTITION p06 VALUES LESS THAN (7),
  PARTITION p07 VALUES LESS THAN (8),
  PARTITION p08 VALUES LESS THAN (9),
  PARTITION p09 VALUES LESS THAN (10),
  PARTITION p10 VALUES LESS THAN (11),
  PARTITION p11 VALUES LESS THAN (12),
  PARTITION p12 VALUES LESS THAN (13),
  PARTITION p13 VALUES LESS THAN (14),
  PARTITION p14 VALUES LESS THAN (15),
  PARTITION p15 VALUES LESS THAN (16),
  PARTITION p16 VALUES LESS THAN (MAXVALUE)
)
AS SELECT * FROM yellow_pages;

ALTER TABLE yellow_pages_part_spatial
  ADD CONSTRAINT yellow_pages_part_spatial_pk PRIMARY KEY (id);
