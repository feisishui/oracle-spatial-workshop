==========================================================
Advanced Indexing / Partitioning
==========================================================

1) Load data for the partitioning lab

  01_IMPORT.BAT

  Import file YP_DATA.DMP. This will create and load the
  following table:

  YELLOW_PAGES     360600 rows

2) Create indexes on the YELLOW_PAGES table

  02_CREATE_NON_PART_SPATIAL_INDEX.SQL

  Creates the spatial index on the yellow pages table

  02_CREATE_NON_PART_CATEGORY_INDEX.SQL

  Creates the category index on the yellow pages table

3) Create a partitionned table

  03_CREATE_PART_TABLE.SQL

  This creates table YELLOW_PAGES_PART.

4) Create a partitionned spatial index on that table

  04_CREATE_PART_SPATIAL_INDEX.SQL

5) Perform queries on the non-partitionned table

  Count the number of restaurants within 8 miles of point (-73.8, 40.7)
  Count the number of restaurants and hotels within 8 miles of point (-73.8, 40.7)
  Count the number of businesses of any kind within 8 miles of point (-73.8, 40.7)

  05_COUNT_QUERY_NON_PART.SQL

6) Perform the same queries on the partitionned table

  Count the number of restaurants within 8 miles of point (-73.8, 40.7)
  Count the number of restaurants and hotels within 8 miles of point (-73.8, 40.7)
  Count the number of businesses of any kind within 8 miles of point (-73.8, 40.7)

  06_COUNT_QUERY_PART.SQL

7) Introduce new POI category

  Use the "split partition" technique to add a new partition for category 7.

  07_NEW_CATEGORY.SQL

8) Move rows between partition

  Update the category of some of the POIs in partition 6. The rows should move to
  the new partition P7.

  08_MOVE_ROWS.SQL

9) Rebuild the index on a partition

  Extract the rows from partition P6 into a table, then index that table.
  Finally use the "partition exchange" technique to swap this table into
  the partitionned table as partition P6.

  09_REBUILD_PARTITION_INDEX.SQL

10) Replace the data in a partition

  We have received a new table called RESTAURANTS. Load it into the partitionned
  table (partition P1) with minimum disruption.

  Create an empty table with the same structure as the partitionned table, and
  fill it with the content of the RESTAURANTS table. Create all indexes (including
  the spatial index) and finally exchange that table with partition P1.

  10_REPLACE_PARTITION_DATA.SQL



