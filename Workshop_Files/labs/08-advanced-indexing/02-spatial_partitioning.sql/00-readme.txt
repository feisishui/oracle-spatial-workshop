==========================================================
Advanced Indexing / Spatial Partitioning
==========================================================

1) Create a partitioning grid table

  01_CREATE_PARTITIONING_GRID.SQL

  Create the PARTITIONING_GRID table and populate it with a grid of 16 cells
  (4 x 4) on the area covered by the geographic locations in the YELLOW_PAGES table.

  Also create a spatial index on the PARTITIONING_GRID table.

2) Distribute YELLOW_PAGES

  02_DISTRIBUTE_YELLOW_PAGES.SQL

  Add a CELL_ID column to the YELLOW_PAGES table, then populate it by matching the
  locations with the cells in the partitioning grid.

3) Create a partitionned table

  03_CREATE_PART_TABLE.SQL

  This creates table YELLOW_PAGES_PART_SPATIAL.

4) Create a partitionned spatial index on that table

  04_CREATE_PART_SPATIAL_INDEX.SQL

5) Perform queries on the partitionned table

  Count the number of restaurants within 8 miles of point (-73.8, 40.7)
  Count the number of restaurants and hotels within 8 miles of point (-73.8, 40.7)
  Count the number of businesses of any kind within 8 miles of point (-73.8, 40.7)

  05_COUNT_QUERY_PART.SQL

6) Create trigger for automatic spatial allocation

  06_TRIGGER_PICK_CELL.SQL

  Create a trigger to automatically get the id of the cell that contains a new
  or updated yellow pages record.

7) Insert new yellow pages

  07_INSERT_YP.SQL

  Insert a few new yellow pages records and verify that they get allocated to the right
  grid cells (= partition).
